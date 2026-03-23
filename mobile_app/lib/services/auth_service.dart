import 'dart:async';

<<<<<<< HEAD
=======
import 'package:dio/dio.dart';
>>>>>>> origin/codex/run-app-on-created-device-vcn9pc
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config.dart';

class AuthService {
  AuthService._(this._client);

  final SupabaseClient? _client;

  static Future<AuthService> create() async {
<<<<<<< HEAD
    if (!AppConfig.hasSupabaseConfig) {
=======
    final config = await _loadConfig();
    if (config == null) {
>>>>>>> origin/codex/run-app-on-created-device-vcn9pc
      return AuthService._(null);
    }

    await Supabase.initialize(
<<<<<<< HEAD
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
=======
      url: config.$1,
      anonKey: config.$2,
>>>>>>> origin/codex/run-app-on-created-device-vcn9pc
    );

    return AuthService._(Supabase.instance.client);
  }

<<<<<<< HEAD
=======
  static Future<(String, String)?> _loadConfig() async {
    if (AppConfig.hasSupabaseConfig) {
      return (AppConfig.supabaseUrl, AppConfig.supabaseAnonKey);
    }

    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
      final res = await dio.get('/api/mobile/config');
      final data = res.data as Map<String, dynamic>;
      final url = (data['supabase_url'] as String?) ?? '';
      final anonKey = (data['supabase_anon_key'] as String?) ?? '';
      final authEnabled = data['auth_enabled'] == true;
      if (!authEnabled || url.isEmpty || anonKey.isEmpty) return null;
      return (url, anonKey);
    } catch (_) {
      return null;
    }
  }

>>>>>>> origin/codex/run-app-on-created-device-vcn9pc
  bool get isConfigured => _client != null;

  Session? get currentSession => _client?.auth.currentSession;

  bool get isLoggedIn => currentSession != null;

  Stream<Session?> sessionChanges() async* {
    yield currentSession;
    if (_client == null) return;
    yield* _client!.auth.onAuthStateChange.map((event) => event.session);
  }

  Future<String?> getAccessToken() async => currentSession?.accessToken;

  Future<void> signInWithGoogle() async {
    if (_client == null) {
      throw StateError('Connexion Google indisponible: Supabase n’est pas configuré.');
    }

    await _client!.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConfig.authRedirectUrl,
    );
  }

  Future<void> signOut() async {
    if (_client == null) return;
    await _client!.auth.signOut();
  }
}
