import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationService {
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static Future<void> saveTokenForUser(String userId, String token) async {
    final firestore = FirebaseFirestore.instance;
    final duplicates = await firestore.collection('users').where('fcmToken', isEqualTo: token).get();
    for (final doc in duplicates.docs) {
      if (doc.id != userId) await doc.reference.update({'fcmToken': FieldValue.delete()});
    }
    await firestore.collection('users').doc(userId).set({'fcmToken': token}, SetOptions(merge: true));
  }
  static Future<void> init(String userId) async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    final token = await messaging.getToken();
    if (token != null) await saveTokenForUser(userId, token);
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen((token) => saveTokenForUser(userId, token));
  }
  static Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }
}
