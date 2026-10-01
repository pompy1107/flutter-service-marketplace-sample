import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileClientScreen extends StatefulWidget {
  const EditProfileClientScreen({super.key});
  @override State<EditProfileClientScreen> createState() => _EditProfileClientScreenState();
}
class _EditProfileClientScreenState extends State<EditProfileClientScreen> {
  final name = TextEditingController();
  final city = TextEditingController();
  Future<void> save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({'clientName': name.text.trim(),'city': city.text.trim(),'clientProfileCompleted': true}, SetOptions(merge: true));
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Client profile')), body: Padding(padding: const EdgeInsets.all(24), child: Column(children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')), TextField(controller: city, decoration: const InputDecoration(labelText: 'City')), const SizedBox(height: 16), ElevatedButton(onPressed: save, child: const Text('Save profile'))])));
}
