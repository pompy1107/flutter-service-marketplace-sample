import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> saveUserRole(String role) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final ref = _db.collection('users').doc(user.uid);
    final doc = await ref.get();
    final data = doc.data() ?? {};
    final roles = Map<String,dynamic>.from(data['roles'] ?? {});
    roles[role] = true;
    await ref.set({'email': user.email,'role': role,'activeRole': role,'roles': roles,'createdAt': data['createdAt'] ?? FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }
  Future<void> switchActiveRole(String role) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).set({'activeRole': role,'role': role,'roles.$role': true}, SetOptions(merge: true));
  }
}
