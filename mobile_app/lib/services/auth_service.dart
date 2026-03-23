import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config.dart';

class AuthService {
  AuthService._(this._client);

  final SupabaseClient? _client;

  static Future<AuthService> create() async {
    if (!AppConfig.hasSupabaseConfig) {
      return AuthService._(null);
    }

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );

    return AuthService._(Supabase.instance.client);
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
      redirectTo: AppConfig.authRedirectUrl,
    );
  }

  Future<void> signOut() async {
    if (_client == null) return;
    await _client!.auth.signOut();
  }
}
