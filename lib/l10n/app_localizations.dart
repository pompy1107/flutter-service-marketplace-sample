import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);
  bool get isRo => locale.languageCode == 'ro';

  static AppLocalizations? of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations);
  static const supportedLocales = [Locale('en'), Locale('ro')];
  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[_AppLocalizationsDelegate(), DefaultMaterialLocalizations.delegate, DefaultWidgetsLocalizations.delegate, DefaultCupertinoLocalizations.delegate];

  String get appName => 'Service Marketplace';
  String get language => isRo ? 'Limbă' : 'Language';
  String get systemLanguage => isRo ? 'Limba sistemului' : 'System language';
  String get romanian => 'Română';
  String get english => 'English';
  String get loginWelcome => isRo ? 'Bine ai revenit' : 'Welcome back';
  String get loginEmailNotVerified => isRo ? 'Adresa de email nu este verificată.' : 'Email address is not verified.';
  String get loginInvalidCredentials => isRo ? 'Date de autentificare incorecte.' : 'Invalid credentials.';
  String get loginGenericError => isRo ? 'Autentificarea a eșuat.' : 'Sign in failed.';
  String get googleLoginFailed => isRo ? 'Autentificarea Google a eșuat.' : 'Google sign in failed.';
  String get appleLoginFailed => isRo ? 'Autentificarea Apple a eșuat.' : 'Apple sign in failed.';
  String get resetPasswordEnterEmail => isRo ? 'Introdu adresa de email.' : 'Enter your email address.';
  String get resetPasswordEmailSent => isRo ? 'Emailul de resetare a fost trimis.' : 'Password reset email sent.';
  String get resetPasswordEmailFailed => isRo ? 'Nu am putut trimite emailul.' : 'Could not send reset email.';
  String get resetPasswordUserNotFound => isRo ? 'Utilizatorul nu a fost găsit.' : 'User not found.';
  String get resetPasswordInvalidEmail => isRo ? 'Adresa de email nu este validă.' : 'Invalid email address.';
  String get verificationEnterCredentials => isRo ? 'Completează emailul și parola.' : 'Enter email and password.';
  String get verificationEmailResent => isRo ? 'Emailul de verificare a fost retrimis.' : 'Verification email resent.';
  String get verificationEmailFailed => isRo ? 'Retrimiterea a eșuat.' : 'Could not resend verification email.';
  String get email => 'Email';
  String get password => isRo ? 'Parolă' : 'Password';
  String get resendEmail => isRo ? 'Retrimite emailul' : 'Resend email';
  String get forgotPassword => isRo ? 'Ai uitat parola?' : 'Forgot password?';
  String get signingIn => isRo ? 'Autentificare...' : 'Signing in...';
  String get signIn => isRo ? 'Intră în cont' : 'Sign in';
  String get continueWithGoogle => isRo ? 'Continuă cu Google' : 'Continue with Google';
  String get continueWithApple => isRo ? 'Continuă cu Apple' : 'Continue with Apple';
  String get signUp => isRo ? 'Creează cont' : 'Create account';
  String get registerVerificationSent => isRo ? 'Ți-am trimis un email de verificare.' : 'Verification email sent.';
  String get registerTitle => isRo ? 'Înregistrare' : 'Register';
  String get createAccount => isRo ? 'Creează cont' : 'Create account';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override bool isSupported(Locale locale) => ['en','ro'].contains(locale.languageCode);
  @override Future<AppLocalizations> load(Locale locale) => SynchronousFuture(AppLocalizations(locale));
  @override bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
