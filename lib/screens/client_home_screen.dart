import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/job_service.dart';
import '../services/auth_service.dart';

class ClientHomeScreen extends StatelessWidget {
  ClientHomeScreen({super.key});
  final JobService jobs = JobService();
  final AuthService auth = AuthService();

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client dashboard'), actions: [IconButton(onPressed: auth.logout, icon: const Icon(Icons.logout))]),
      body: StreamBuilder<QuerySnapshot>(
        stream: jobs.getClientJobs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No jobs yet.'));
          return ListView.builder(itemCount: docs.length, itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String,dynamic>;
            return ListTile(title: Text(data['title']?.toString() ?? 'Job'), subtitle: Text('Status: ${data['status'] ?? '-'}'), trailing: Text('${data['client_budget'] ?? '-'} ${data['currencyCode'] ?? ''}'));
          });
        },
      ),
    );
  }
}
