import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileMeseriasScreen extends StatefulWidget {
  const EditProfileMeseriasScreen({super.key});
  @override State<EditProfileMeseriasScreen> createState() => _EditProfileMeseriasScreenState();
}
class _EditProfileMeseriasScreenState extends State<EditProfileMeseriasScreen> {
  final businessName = TextEditingController();
  final city = TextEditingController();
  double radius = 20;
  Future<void> save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({'businessName': businessName.text.trim(),'workCity': city.text.trim(),'workRadiusKm': radius,'meseriasProfileCompleted': true}, SetOptions(merge: true));
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Professional profile')), body: ListView(padding: const EdgeInsets.all(24), children: [TextField(controller: businessName, decoration: const InputDecoration(labelText: 'Business / display name')), TextField(controller: city, decoration: const InputDecoration(labelText: 'Service city')), const SizedBox(height: 16), Text('Work radius: ${radius.round()} km'), Slider(value: radius, min: 5, max: 100, divisions: 19, onChanged: (v) => setState(() => radius = v)), ElevatedButton(onPressed: save, child: const Text('Save profile'))]));
}
