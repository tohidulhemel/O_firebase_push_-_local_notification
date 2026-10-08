import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../common/app_logo.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppLogo(),
        const SizedBox(height: 28),
        Text(title, style: AppTextStyles.heading, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(subtitle,
            style: AppTextStyles.subtitle, textAlign: TextAlign.center),
      ],
    );
  }
}