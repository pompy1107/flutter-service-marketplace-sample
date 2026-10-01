import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/locale_scope.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;
  bool _emailNotVerified = false;

  Future<void> _login() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _error = null;
      _emailNotVerified = false;
    });
    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.code) {
          case 'email-not-verified':
            _error = l10n.loginEmailNotVerified;
            _emailNotVerified = true;
            break;
          case 'invalid-credential':
          case 'wrong-password':
          case 'user-not-found':
            _error = l10n.loginInvalidCredentials;
            break;
          default:
            _error = l10n.loginGenericError;
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _authService.loginWithGoogle();
    } catch (_) {
      if (mounted) setState(() => _error = l10n.googleLoginFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithApple() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _authService.loginWithApple();
    } catch (_) {
      if (mounted) setState(() => _error = l10n.appleLoginFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.resetPasswordEnterEmail)));
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.resetPasswordEmailSent)));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      var message = l10n.resetPasswordEmailFailed;
      if (e.code == 'user-not-found') message = l10n.resetPasswordUserNotFound;
      if (e.code == 'invalid-email') message = l10n.resetPasswordInvalidEmail;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _resendVerificationEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.verificationEnterCredentials)));
      return;
    }
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      await credential.user?.sendEmailVerification(
        ActionCodeSettings(url: 'https://example.com/email-confirmed/', handleCodeInApp: false),
      );
      await FirebaseAuth.instance.signOut();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.verificationEmailResent)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.verificationEmailFailed)));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeController = LocaleScope.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.language_rounded),
                  onSelected: (value) => value == 'system'
                      ? localeController.useSystemLocale()
                      : localeController.setLocale(Locale(value)),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'system', child: Text(l10n.systemLanguage)),
                    PopupMenuItem(value: 'ro', child: Text('🇷🇴 ${l10n.romanian}')),
                    PopupMenuItem(value: 'en', child: Text('🇬🇧 ${l10n.english}')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.loginWelcome, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 24),
              TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: l10n.email, prefixIcon: const Icon(Icons.email_outlined))),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: l10n.password,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: Colors.red))),
              if (_emailNotVerified) TextButton(onPressed: _resendVerificationEmail, child: Text(l10n.resendEmail)),
              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _resetPassword, child: Text(l10n.forgotPassword))),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isLoading ? null : _login, child: Text(_isLoading ? l10n.signingIn : l10n.signIn))),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: OutlinedButton(onPressed: _isLoading ? null : _loginWithGoogle, child: Text(l10n.continueWithGoogle))),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: OutlinedButton(onPressed: _isLoading ? null : _loginWithApple, child: Text(l10n.continueWithApple))),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: Text(l10n.signUp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
