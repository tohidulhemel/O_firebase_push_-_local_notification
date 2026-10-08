import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../common/app_button.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'Continue with Google',
      variant: AppButtonVariant.outlined,
      isLoading: isLoading,
      onPressed: onPressed,
      // Simple "G" mark; swap for the official asset if you add one.
      leading: Text(
        'G',
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF4285F4),
        ),
      ),
    );
  }
}