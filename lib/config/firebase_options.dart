import 'package:firebase_core/firebase_core.dart';
class PortfolioFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: 'YOUR_FIREBASE_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_APP_ID', defaultValue: 'YOUR_FIREBASE_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: 'YOUR_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'YOUR_PROJECT_ID'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: 'YOUR_BUCKET'),
  );
}
