import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> createNotification({required String userId, required String title, required String body, required String type, String? jobId}) async {
    await _db.collection('notifications').add({'user_id': userId,'title': title,'body': body,'type': type,'jobId': jobId,'read': false,'createdAt': FieldValue.serverTimestamp()});
  }
  Stream<QuerySnapshot> getMyNotifications() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _db.collection('notifications').where('user_id', isEqualTo: user.uid).orderBy('createdAt', descending: true).snapshots();
  }
  Stream<int> getUnreadCount() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _db.collection('notifications').where('user_id', isEqualTo: user.uid).where('read', isEqualTo: false).snapshots().map((s) => s.docs.length);
  }
  Future<void> markAsRead(String id) => _db.collection('notifications').doc(id).update({'read': true});
}
