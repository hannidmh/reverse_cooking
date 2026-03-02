import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/favorites_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/scan_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

final apiProvider = Provider<ApiService>((ref) => ApiService());

void main() {
  runApp(const ProviderScope(child: FoodAiMobileApp()));
}

class FoodAiMobileApp extends StatelessWidget {
  const FoodAiMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodAI Mobile',
      theme: AppTheme.dark(),
      home: const MainTabs(),
    );
  }
}

class MainTabs extends ConsumerStatefulWidget {
  const MainTabs({super.key});

  @override
  ConsumerState<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends ConsumerState<MainTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final api = ref.watch(apiProvider);
    final pages = [
      ScanScreen(api: api),
      HistoryScreen(api: api),
      FavoritesScreen(api: api),
      ProfileScreen(api: api),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('FoodAI')),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (v) => setState(() => _index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.camera_alt_outlined), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historique'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), label: 'Favoris'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
