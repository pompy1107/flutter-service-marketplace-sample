import 'package:flutter/material.dart';
import '../services/user_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});
  @override State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}
class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final phone = TextEditingController();
  final users = UserService();
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Complete profile')),
    body: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone')),
      const SizedBox(height: 16),
      const Text('Production version also uploads and validates a profile image.'),
    ])),
  );
}
