import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:gr_jobs/all_pages/models_supabase/user_model.dart' as app_models;
import 'package:gr_jobs/all_pages/service/user_service.dart';

class AuthProvider with ChangeNotifier {
  late supabase.SupabaseClient _supabase;
  supabase.Session? _session;
  bool _isAuthenticated = false;
  app_models.User? _appUser;
  final UserProvider _userProvider;
  bool _disposed = false;

  bool get isAuthenticated => _isAuthenticated;
  supabase.User? get authUser => _session?.user;
  app_models.User? get appUser => _appUser;

  AuthProvider(supabase.Session? initialSession, this._userProvider) {
    _initialize();
    if (initialSession != null) {
      _handleAuthChange(supabase.AuthChangeEvent.signedIn, initialSession);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _checkIfDisposed() {
    if (_disposed) {
      throw StateError('AuthProvider уже disposed');
    }
  }

  Future<void> _initialize() async {
    _checkIfDisposed();
    _supabase = supabase.Supabase.instance.client;

    _supabase.auth.onAuthStateChange.listen((event) {
      if (!_disposed) {
        _handleAuthChange(event.event, event.session);
      }
    });
  }

  Future<void> initializeUser() async {
    _checkIfDisposed();
    final session = _supabase.auth.currentSession;

    if (session != null) {
      await _handleAuthChange(supabase.AuthChangeEvent.signedIn, session);
    }
  }

  Future<void> _handleAuthChange(supabase.AuthChangeEvent event, supabase.Session? session) async {
    if (_disposed) return;

    _session = session;

    if (event == supabase.AuthChangeEvent.signedIn && session != null) {
      _isAuthenticated = true;
      try {
        await _ensureAppUserExists(session.user);
      } catch (e) {
        print('Ошибка при инициализации пользователя: $e');
      }
    } else if (event == supabase.AuthChangeEvent.signedOut) {
      _isAuthenticated = false;
      _appUser = null;
    }

    notifyListeners();
  }

  Future<void> _ensureAppUserExists(supabase.User authUser) async {
    _checkIfDisposed();
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('supabase_user_id', authUser.id)
          .maybeSingle();

      if (response == null) {
        final insertResponse = await _supabase.from('users').insert({
          'supabase_user_id': authUser.id,
          'email': authUser.email,
          'created_at': DateTime.now().toIso8601String(),
        }).select().single();

        if (insertResponse != null) {
          print('Создана новая запись пользователя с ID: ${insertResponse['id']}');
          _appUser = app_models.User.fromJson(insertResponse);
        } else {
          throw Exception('Не удалось создать пользователя');
        }
      } else {
        _appUser = app_models.User.fromJson(response as Map<String, dynamic>);
      }

      notifyListeners();
    } catch (e) {
      print('Ошибка создания/проверки пользователя: $e');
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    _checkIfDisposed();
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null && response.session != null) {
        await _handleAuthChange(supabase.AuthChangeEvent.signedIn, response.session);
      }
    } catch (e) {
      print('Ошибка входа: $e');
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    _checkIfDisposed();
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null && response.session != null) {
        await _handleAuthChange(supabase.AuthChangeEvent.signedIn, response.session);
      }
    } catch (e) {
      print('Ошибка регистрации: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    _checkIfDisposed();
    try {
      await _supabase.auth.signOut();
      await _handleAuthChange(supabase.AuthChangeEvent.signedOut, null);
    } catch (e) {
      print('Ошибка выхода: $e');
      rethrow;
    }
  }

  Future<void> fetchUser(String userId) async {
    _checkIfDisposed();
    try {
      await _userProvider.fetchUser(userId);
      if (!_disposed) {
        _appUser = _userProvider.user;
        notifyListeners();
      }
    } catch (e) {
      if (!_disposed) {
        print("Ошибка загрузки профиля: $e");
        _appUser = null;
        notifyListeners();
      }
    }
  }

  void additionalLogin() {
    _checkIfDisposed();
    _isAuthenticated = true;
    if (!_disposed) notifyListeners();
  }
}