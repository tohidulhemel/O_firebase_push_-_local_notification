import 'package:flutter/widgets.dart';

import '../constants/app_constants.dart';

class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  /// Login: only checks that something was typed.
  static String? requiredPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  /// Sign up: Firebase requires at least 6 characters.
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static FormFieldValidator<String> confirmPassword(
    TextEditingController password,
  ) {
    return (value) {
      if (value == null || value.isEmpty) return 'Please confirm your password';
      if (value != password.text) return 'Passwords do not match';
      return null;
    };
  }

  static String? taskTitle(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Title is required';
    if (v.length > AppConstants.maxTitleLength) {
      return 'Title must be ${AppConstants.maxTitleLength} characters or fewer';
    }
    return null;
  }
}