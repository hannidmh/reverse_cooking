import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'widgets/auth_required_view.dart';
import 'widgets/foodai_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
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
        message: 'Connecte-toi ou inscris-toi pour afficher tes favoris.',
        onSignInRequested: onSignInRequested,
      );
    }

    return FutureBuilder<List<FavoriteItem>>(
      future: api.getFavorites(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur favoris: ${snapshot.error}'));
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(
            child: Text('Aucun favori pour le moment.'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final it = items[i];
            return FoodAiCard(
              child: ListTile(
                leading: const Icon(Icons.favorite, color: Colors.pinkAccent),
                title: Text(it.predictedDish),
                subtitle: Text('${(it.confidence * 100).toStringAsFixed(1)}%'),
              ),
            );
          },
        );
      },
    );
  }
}
