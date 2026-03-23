import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'widgets/auth_required_view.dart';
import 'widgets/foodai_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.api,
    required this.auth,
    required this.onSignInRequested,
  });

  final ApiService api;
  final AuthService auth;
  final Future<void> Function() onSignInRequested;

  @override
  Widget build(BuildContext context) {
    if (!auth.isLoggedIn) {
      return AuthRequiredView(
        title: 'Connexion requise',
        message: 'Connecte-toi ou inscris-toi pour afficher ton profil.',
        onSignInRequested: onSignInRequested,
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: api.getProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur profil: ${snapshot.error}'));
        }
        final p = snapshot.data ?? {};
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FoodAiCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Profil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Email: ${p['email'] ?? '-'}'),
                  Text('Prénom: ${p['first_name'] ?? '-'}'),
                  Text('Nom: ${p['last_name'] ?? '-'}'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
