import 'package:flutter/material.dart';
import '../services/user_service.dart';

class SelectRoleScreen extends StatelessWidget {
  SelectRoleScreen({super.key});
  final UserService _users = UserService();

  Future<void> _choose(BuildContext context, String role) async {
    await _users.saveUserRole(role);
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your role')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Use the marketplace as', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => _choose(context, 'client'), icon: const Icon(Icons.person_search), label: const Text('Client'))),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => _choose(context, 'meserias'), icon: const Icon(Icons.handyman), label: const Text('Professional'))),
        ]),
      ),
    );
  }
}
