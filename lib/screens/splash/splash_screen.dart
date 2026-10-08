import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/common/app_logo.dart';

/// Shown while Firebase Auth restores the saved session.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
          child: Column(
            children: [
              const Spacer(flex: 3),
              const AppLogo(size: 96),
              const SizedBox(height: 28),
              Text(AppConstants.appName,
                  style: AppTextStyles.heading, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'A simple task manager powered by Flutter & Firestore',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text('Initializing app...', style: AppTextStyles.body),
              const SizedBox(height: 24),
              Text('FLUTTER  •  FIREBASE', style: AppTextStyles.footer),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}