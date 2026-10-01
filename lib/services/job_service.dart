import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'notification_service.dart';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';

class JobService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final NotificationService _notificationService = NotificationService();

  String _normalizeText(String value) {
    return value.toLowerCase().trim().replaceAll('ă', 'a').replaceAll('â', 'a').replaceAll('î', 'i').replaceAll('ș', 's').replaceAll('ş', 's').replaceAll('ț', 't').replaceAll('ţ', 't');
  }

  double _calculateDistanceKm(double lat1, double lng1, double lat2, double lng2) {
    const earthRadius = 6371;
    final dLat = (lat2 - lat1) * (pi / 180);
    final dLng = (lng2 - lng1) * (pi / 180);
    final a = (sin(dLat / 2) * sin(dLat / 2)) + cos(lat1 * (pi / 180)) * cos(lat2 * (pi / 180)) * (sin(dLng / 2) * sin(dLng / 2));
    return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  Future<void> createJob({
    required String title,
    required String description,
    required String category,
    String? categoryName,
    String? customCategory,
    required double budget,
    required String jobCity,
    String? jobLat,
    String? jobLng,
    String? jobAddress,
    String? jobCounty,
    List<File> imageFiles = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final userDoc = await _db.collection('users').doc(user.uid).get();
    final countryCode = (userDoc.data()?['countryCode'] ?? 'RO').toString().toUpperCase();
    final currencyCode = countryCode == 'GB' ? 'GBP' : 'RON';
    final imageUrls = <String>[];
    for (int i = 0; i < imageFiles.length && i < 3; i++) {
      final ref = _storage.ref().child('job_images').child(user.uid).child('${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
      await ref.putFile(imageFiles[i]);
      imageUrls.add(await ref.getDownloadURL());
    }
    await _db.collection('jobs').add({
      'title': title,
      'description': description,
      'category': category,
      'categoryName': categoryName,
      'customCategory': customCategory,
      'client_id': user.uid,
      'countryCode': countryCode,
      'currencyCode': currencyCode,
      'client_budget': budget,
      'jobCity': jobCity,
      'jobCityNormalized': _normalizeText(jobCity),
      'jobCounty': jobCounty,
      'jobLat': jobLat,
      'jobLng': jobLng,
      'jobAddress': jobAddress,
      'locationVisibility': 'accepted_only',
      'status': 'open',
      'image_urls': imageUrls,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> submitOffer({required String jobId, required double price, required String message}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final jobRef = _db.collection('jobs').doc(jobId);
    final existing = await jobRef.collection('offers').where('meserias_id', isEqualTo: user.uid).limit(1).get();
    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update({'price': price, 'message': message, 'status': 'pending', 'updatedAt': FieldValue.serverTimestamp()});
    } else {
      await jobRef.collection('offers').add({'meserias_id': user.uid, 'price': price, 'message': message, 'status': 'pending', 'createdAt': FieldValue.serverTimestamp()});
    }
  }

  Stream<QuerySnapshot> getOffersForJob(String jobId) => _db.collection('jobs').doc(jobId).collection('offers').orderBy('createdAt').snapshots();

  Future<void> acceptOffer({required String jobId, required String offerId}) async {
    final jobRef = _db.collection('jobs').doc(jobId);
    final offer = await jobRef.collection('offers').doc(offerId).get();
    final data = offer.data();
    if (data == null) return;
    await jobRef.update({'status': 'assigned', 'meserias_id': data['meserias_id'], 'agreed_price': (data['price'] ?? 0).toDouble(), 'accepted_offer_id': offerId});
    final allOffers = await jobRef.collection('offers').get();
    for (final doc in allOffers.docs) {
      await doc.reference.update({'status': doc.id == offerId ? 'accepted' : 'rejected'});
    }
  }

  Future<void> startJob(String jobId) => _db.collection('jobs').doc(jobId).update({'status': 'in_progress'});

  Future<void> completeJob(String jobId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final jobRef = _db.collection('jobs').doc(jobId);
    final snap = await jobRef.get();
    final data = snap.data();
    if (data == null || data['meserias_id'] != user.uid || data['status'] != 'in_progress') return;
    await jobRef.update({'status': 'work_completed_waiting_confirmation', 'workCompletedAt': FieldValue.serverTimestamp(), 'completed_by_meserias': true});
    final clientId = data['client_id'];
    if (clientId != null) {
      await _notificationService.createNotification(userId: clientId, title: 'Job marked as completed', body: 'Please confirm the completed work.', type: 'work_completed_waiting_confirmation', jobId: jobId);
    }
  }

  Future<void> confirmWorkCompletedByClient(String jobId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final jobRef = _db.collection('jobs').doc(jobId);
    final snap = await jobRef.get();
    final data = snap.data();
    if (data == null || data['client_id'] != user.uid || data['status'] != 'work_completed_waiting_confirmation') return;
    await jobRef.update({'status': 'completed', 'payment_status': 'release_pending', 'confirmedByClientAt': FieldValue.serverTimestamp(), 'completedAt': FieldValue.serverTimestamp()});
    await FirebaseFunctions.instance.httpsCallable('releasePaymentToMeserias').call({'jobId': jobId});
  }

  Future<void> reportProblemByClient({required String jobId, required String reason}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('jobs').doc(jobId).update({'status': 'disputed', 'payment_status': 'disputed', 'disputeCreatedAt': FieldValue.serverTimestamp(), 'disputeCreatedBy': user.uid, 'disputeReason': reason.trim()});
  }

  Stream<QuerySnapshot> getOpenJobs() => _db.collection('jobs').where('status', isEqualTo: 'open').orderBy('createdAt', descending: true).snapshots();

  Stream<QuerySnapshot> getMeseriasJobs() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _db.collection('jobs').where('meserias_id', isEqualTo: user.uid).where('status', whereIn: ['assigned','payment_held','in_progress','work_completed_waiting_confirmation','completed','disputed','cancelled']).snapshots();
  }

  Stream<QuerySnapshot> getClientJobs() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _db.collection('jobs').where('client_id', isEqualTo: user.uid).snapshots();
  }

  Future<void> startClientPayment(String jobId) async {
    final result = await FirebaseFunctions.instance.httpsCallable('createClientCheckoutSession').call({'jobId': jobId});
    final url = (result.data as Map)['url']?.toString();
    if (url == null || url.isEmpty) throw Exception('payment-link-missing');
    final opened = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!opened) throw Exception('payment-page-open-failed');
  }
}
