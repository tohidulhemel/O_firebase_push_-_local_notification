import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/constants/app_constants.dart';

/// A readable error that is safe to show directly in the UI.
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  bool _googleInitialized = false;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signUp({required String email, required String password}) {
    return _guard(() => _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        ));
  }

  Future<void> signIn({required String email, required String password}) {
    return _guard(() => _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        ));
  }

  Future<void> sendPasswordReset(String email) {
    return _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));
  }

  /// Returns normally (without signing in) if the user cancels the picker.
  Future<void> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthFailure(
          'Google sign-in did not return a valid token. Please try again.',
        );
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      debugPrint('Google sign-in failed: $e');
      throw const AuthFailure('Google sign-in failed. Please try again.');
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException (google): ${e.code}');
      throw AuthFailure(_messageFor(e));
    }
  }

  Future<void> signOut() async {
    try {
      await _ensureGoogleInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('Google sign-out skipped: $e');
    }
    await _auth.signOut();
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: AppConstants.googleWebClientId,
    );
    _googleInitialized = true;
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code}');
      throw AuthFailure(_messageFor(e));
    }
  }

  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase Console.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}