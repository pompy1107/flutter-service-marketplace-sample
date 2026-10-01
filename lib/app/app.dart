import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../auth/auth_gate.dart';
import '../services/locale_controller.dart';
import '../services/locale_scope.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class HandyGoApp extends StatefulWidget {
  const HandyGoApp({super.key});

  @override
  State<HandyGoApp> createState() => _HandyGoAppState();
}

class _HandyGoAppState extends State<HandyGoApp> {
  final LocaleController _localeController = LocaleController();

  @override
  void initState() {
    super.initState();
    _localeController.loadLocale();
    _localeController.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _localeController.removeListener(_onLocaleChanged);
    _localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      controller: _localeController,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        locale: _localeController.locale,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AuthGate(),
      ),
    );
  }
}
