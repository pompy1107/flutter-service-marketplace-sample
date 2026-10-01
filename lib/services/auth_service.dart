import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'push_notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> login({required String email, required String password}) async {
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = result.user;
    if (user != null) await _saveFcmToken(user);
    return user;
  }
  Future<User?> loginWithGoogle() async {
    final signIn = GoogleSignIn.instance;
    await signIn.initialize();
    final googleUser = await signIn.authenticate();
    final googleAuth = googleUser.authentication;
    final result = await _auth.signInWithCredential(GoogleAuthProvider.credential(idToken: googleAuth.idToken));
    if (result.user != null) await _saveFcmToken(result.user!);
    return result.user;
  }
  Future<User?> loginWithApple() async {
    final provider = AppleAuthProvider()..addScope('email')..addScope('name');
    final result = await _auth.signInWithProvider(provider);
    if (result.user != null) await _saveFcmToken(result.user!);
    return result.user;
  }
  Future<User?> register({required String email, required String password, required String languageCode}) async {
    final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (result.user != null) {
      await result.user!.sendEmailVerification(ActionCodeSettings(url: 'https://example.com/email-confirmed/', handleCodeInApp: false));
      await _auth.signOut();
    }
    return result.user;
  }
  Future<void> logout() async {
    final user = _auth.currentUser;
    await PushNotificationService.dispose();
    if (user != null) {
      try { await _firestore.collection('users').doc(user.uid).update({'fcmToken': FieldValue.delete()}); } catch (_) {}
    }
    await _auth.signOut();
  }
  Future<void> _saveFcmToken(User user) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await PushNotificationService.saveTokenForUser(user.uid, token);
  }
}
