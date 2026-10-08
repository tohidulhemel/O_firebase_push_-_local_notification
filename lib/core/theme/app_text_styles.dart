import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Getters (not fields) because GoogleFonts styles are created at runtime.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get heading => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      );

  static TextStyle get subtitle =>
      GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary);

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: AppColors.textSecondary,
      );

  static TextStyle get input =>
      GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimary);

  static TextStyle get hint =>
      GoogleFonts.inter(fontSize: 16, color: AppColors.textHint);

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get link => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  static TextStyle get body =>
      GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary);

  static TextStyle get caption =>
      GoogleFonts.inter(fontSize: 12, color: AppColors.textHint);

  static TextStyle get footer => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
        color: AppColors.textHint,
      );

  static TextStyle get error => GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.error,
      );
}