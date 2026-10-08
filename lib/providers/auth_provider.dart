import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service) {
    _subscription = _service.authStateChanges.listen((user) {
      _user = user;
      _isInitialized = true;
      notifyListeners();
    });
  }

  final AuthService _service;
  late final StreamSubscription<User?> _subscription;

  User? _user;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn({required String email, required String password}) =>
      _run(() => _service.signIn(email: email, password: password));

  Future<bool> signUp({required String email, required String password}) =>
      _run(() => _service.signUp(email: email, password: password));

  Future<bool> signInWithGoogle() => _run(_service.signInWithGoogle);

  Future<bool> sendPasswordReset(String email) =>
      _run(() => _service.sendPasswordReset(email));

  Future<bool> signOut() => _run(_service.signOut);

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}