import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.text = 'or continue with'});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(text, style: AppTextStyles.caption.copyWith(fontSize: 13)),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}