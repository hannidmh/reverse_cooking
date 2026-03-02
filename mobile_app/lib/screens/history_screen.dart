import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import 'widgets/foodai_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.api});

  final ApiService api;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HistoryItem>>(
      future: api.getHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur historique: ${snapshot.error}'));
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('Aucun scan enregistré.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final it = items[i];
            return FoodAiCard(
              child: ListTile(
                title: Text(it.predictedDish),
                subtitle: Text('${(it.confidence * 100).toStringAsFixed(1)}% • ${it.servings} portions'),
                trailing: Text(it.createdAt.split('T').first),
              ),
            );
          },
        );
      },
    );
  }
}
