import 'dart:async';

import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config.dart';

class AuthService {
<<<<<<< HEAD
  AuthService._(this._client);

  final SupabaseClient? _client;
=======
  AuthService._(this._client, this._redirectUrl);

  final SupabaseClient? _client;
  final String _redirectUrl;
>>>>>>> origin/codex/run-app-on-created-device-pqcgc5

  static Future<AuthService> create() async {
    final config = await _loadConfig();
    if (config == null) {
<<<<<<< HEAD
      return AuthService._(null);
=======
      return AuthService._(null, AppConfig.authRedirectUrl);
>>>>>>> origin/codex/run-app-on-created-device-pqcgc5
    }

    await Supabase.initialize(
      url: config.$1,
      anonKey: config.$2,
    );

<<<<<<< HEAD
    return AuthService._(Supabase.instance.client);
  }

  static Future<(String, String)?> _loadConfig() async {
    if (AppConfig.hasSupabaseConfig) {
      return (AppConfig.supabaseUrl, AppConfig.supabaseAnonKey);
=======
    return AuthService._(Supabase.instance.client, config.$3);
  }

  static Future<(String, String, String)?> _loadConfig() async {
    if (AppConfig.hasSupabaseConfig) {
      return (AppConfig.supabaseUrl, AppConfig.supabaseAnonKey, AppConfig.authRedirectUrl);
>>>>>>> origin/codex/run-app-on-created-device-pqcgc5
    }

    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
      final res = await dio.get('/api/mobile/config');
      final data = res.data as Map<String, dynamic>;
      final url = (data['supabase_url'] as String?) ?? '';
      final anonKey = (data['supabase_anon_key'] as String?) ?? '';
<<<<<<< HEAD
      final authEnabled = data['auth_enabled'] == true;
      if (!authEnabled || url.isEmpty || anonKey.isEmpty) return null;
      return (url, anonKey);
=======
      final redirectUrl = (data['redirect_url'] as String?) ?? AppConfig.authRedirectUrl;
      final authEnabled = data['auth_enabled'] == true;
      if (!authEnabled || url.isEmpty || anonKey.isEmpty) return null;
      return (url, anonKey, redirectUrl);
>>>>>>> origin/codex/run-app-on-created-device-pqcgc5
    } catch (_) {
      return null;
    }
  }

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
      redirectTo: _redirectUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() async {
    if (_client == null) return;
    await _client!.auth.signOut();
  }
}
