import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/favorites_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/scan_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

final authProvider = Provider<AuthService>((ref) => throw UnimplementedError());
final apiProvider = Provider<ApiService>((ref) => ApiService(auth: ref.watch(authProvider)));
final authSessionProvider = StreamProvider<Session?>((ref) => ref.watch(authProvider).sessionChanges());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = await AuthService.create();

  runApp(
    ProviderScope(
      overrides: [authProvider.overrideWithValue(auth)],
      child: const FoodAiMobileApp(),
    ),
  );
}

class FoodAiMobileApp extends ConsumerWidget {
  const FoodAiMobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authSession = ref.watch(authSessionProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodAI Mobile',
      theme: AppTheme.dark(),
      home: authSession.when(
        data: (session) => MainTabs(isLoggedIn: session != null),
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, stackTrace) => const MainTabs(isLoggedIn: false),
      ),
    );
  }
}

class MainTabs extends ConsumerStatefulWidget {
  const MainTabs({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  ConsumerState<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends ConsumerState<MainTabs> {
  int _index = 0;
  bool _showLoginPrompt = true;
  bool _authBusy = false;

  Future<void> _signIn() async {
    final auth = ref.read(authProvider);
    if (!auth.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Connexion Google indisponible. Ajoute SUPABASE_URL et SUPABASE_ANON_KEY au lancement Flutter.',
          ),
        ),
      );
      return;
    }

    setState(() => _authBusy = true);
    try {
      await auth.signInWithGoogle();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de lancer Google: $error')),
      );
    } finally {
      if (mounted) setState(() => _authBusy = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _authBusy = true);
    try {
      await ref.read(authProvider).signOut();
      if (mounted) setState(() => _showLoginPrompt = true);
    } finally {
      if (mounted) setState(() => _authBusy = false);
    }
  }

  @override
  void didUpdateWidget(covariant MainTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoggedIn && !oldWidget.isLoggedIn) {
      _showLoginPrompt = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = ref.watch(apiProvider);
    final auth = ref.watch(authProvider);
    final pages = [
      ScanScreen(api: api, auth: auth, onSignInRequested: _signIn),
      HistoryScreen(api: api, auth: auth, onSignInRequested: _signIn),
      FavoritesScreen(api: api, auth: auth, onSignInRequested: _signIn),
      ProfileScreen(api: api, auth: auth, onSignInRequested: _signIn),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodAI'),
        actions: [
          TextButton.icon(
            onPressed: _authBusy ? null : (widget.isLoggedIn ? _signOut : _signIn),
            icon: Icon(widget.isLoggedIn ? Icons.logout : Icons.login),
            label: Text(widget.isLoggedIn ? 'Déconnexion' : 'Connexion'),
          ),
        ],
      ),
      body: Stack(
        children: [
          pages[_index],
          if (!widget.isLoggedIn && _showLoginPrompt)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.72)),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Connecte-toi avec Google',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Connecte-toi dès maintenant pour activer l’historique, les favoris et ton profil.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: _authBusy ? null : _signIn,
                              icon: const Icon(Icons.account_circle_outlined),
                              label: Text(_authBusy ? 'Connexion...' : 'Continuer avec Google'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => setState(() => _showLoginPrompt = false),
                              child: const Text('Continuer sans compte'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
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
