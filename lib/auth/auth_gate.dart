import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import '../screens/select_role_screen.dart';
import '../screens/client_home_screen.dart';
import '../screens/meserias_home_screen.dart';
import '../screens/complete_profile_screen.dart';
import '../screens/edit_profile_client_screen.dart';
import '../screens/edit_profile_meserias_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!authSnapshot.hasData) return const LoginScreen();
        final user = authSnapshot.data!;

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, userDocSnapshot) {
            if (userDocSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final doc = userDocSnapshot.data;
            final data = doc?.data() as Map<String, dynamic>?;
            final legacyRole = data?['role']?.toString();
            final activeRole = data?['activeRole']?.toString() ?? legacyRole;
            final roles = data?['roles'] as Map<String, dynamic>?;
            final hasClientRole = roles?['client'] == true || legacyRole == 'client';
            final hasMeseriasRole = roles?['meserias'] == true || legacyRole == 'meserias';
            final legacyProfileCompleted = data?['profileCompleted'] == true;
            final clientProfileCompleted = data?['clientProfileCompleted'] == true || (legacyProfileCompleted && legacyRole == 'client');
            final meseriasProfileCompleted = data?['meseriasProfileCompleted'] == true || (legacyProfileCompleted && legacyRole == 'meserias');
            final isActiveProfileCompleted = activeRole == 'client'
                ? clientProfileCompleted
                : activeRole == 'meserias'
                    ? meseriasProfileCompleted
                    : false;
            final isOnboardingCompleted = data?['onboardingCompleted'] == true || legacyProfileCompleted;

            if (!hasClientRole && !hasMeseriasRole) return SelectRoleScreen();
            if (!isOnboardingCompleted) return const CompleteProfileScreen();
            if (!isActiveProfileCompleted) {
              if (activeRole == 'client') return EditProfileClientScreen();
              if (activeRole == 'meserias') return const EditProfileMeseriasScreen();
              return SelectRoleScreen();
            }
            if (activeRole == 'client' && hasClientRole) return ClientHomeScreen();
            if (activeRole == 'meserias' && hasMeseriasRole) return MeseriasHomeScreen();
            if (hasClientRole) return ClientHomeScreen();
            if (hasMeseriasRole) return MeseriasHomeScreen();
            return SelectRoleScreen();
          },
        );
      },
    );
  }
}
