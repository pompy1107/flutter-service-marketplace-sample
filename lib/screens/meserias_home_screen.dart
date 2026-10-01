import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/job_service.dart';
import '../services/auth_service.dart';

class MeseriasHomeScreen extends StatelessWidget {
  MeseriasHomeScreen({super.key});
  final JobService jobs = JobService();
  final AuthService auth = AuthService();

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Professional dashboard'), actions: [IconButton(onPressed: auth.logout, icon: const Icon(Icons.logout))]),
      body: StreamBuilder<QuerySnapshot>(
        stream: jobs.getOpenJobs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          return ListView.builder(itemCount: docs.length, itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String,dynamic>;
            return Card(child: ListTile(leading: const Icon(Icons.work_outline), title: Text(data['title']?.toString() ?? 'Job'), subtitle: Text(data['jobCity']?.toString() ?? ''), trailing: Text('${data['client_budget'] ?? '-'} ${data['currencyCode'] ?? ''}')));
          });
        },
      ),
    );
  }
}
