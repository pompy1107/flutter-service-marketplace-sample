import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});
  final NotificationService notifications = NotificationService();
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Notifications')),
    body: StreamBuilder<QuerySnapshot>(stream: notifications.getMyNotifications(), builder: (_, snapshot) {
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      return ListView(children: snapshot.data!.docs.map((doc) { final d = doc.data() as Map<String,dynamic>; return ListTile(title: Text(d['title']?.toString() ?? ''), subtitle: Text(d['body']?.toString() ?? ''), leading: Icon(d['read'] == true ? Icons.notifications_none : Icons.notifications_active)); }).toList());
    }),
  );
}
