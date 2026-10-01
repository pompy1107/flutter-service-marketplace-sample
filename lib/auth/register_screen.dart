import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final auth = AuthService();
  bool loading = false;
  String? error;
  Future<void> register() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() { loading = true; error = null; });
    try {
      await auth.register(email: email.text.trim(), password: password.text.trim(), languageCode: Localizations.localeOf(context).languageCode);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.registerVerificationSent)));
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => error = e.code);
    } finally { if (mounted) setState(() => loading = false); }
  }
  @override Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(appBar: AppBar(title: Text(l10n.registerTitle)), body: ListView(padding: const EdgeInsets.all(22), children: [TextField(controller: email, decoration: InputDecoration(labelText: l10n.email)), const SizedBox(height: 12), TextField(controller: password, obscureText: true, decoration: InputDecoration(labelText: l10n.password)), if (error != null) Text(error!), const SizedBox(height: 20), ElevatedButton(onPressed: loading ? null : register, child: Text(l10n.createAccount))]));
  }
}
