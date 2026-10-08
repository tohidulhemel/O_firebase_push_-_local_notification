import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum AppButtonVariant { filled, outlined }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.filled,
    this.leading,
    this.trailing,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isFilled = variant == AppButtonVariant.filled;
    final foreground = isFilled ? Colors.white : AppColors.textPrimary;
    final enabled = onPressed != null && !isLoading;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius),
    );

    final content = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 10)],
              Text(label, style: AppTextStyles.button.copyWith(color: foreground)),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: isFilled
          ? ElevatedButton(
              onPressed: enabled ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                elevation: 0,
                shape: shape,
              ),
              child: content,
            )
          : OutlinedButton(
              onPressed: enabled ? onPressed : null,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.border),
                shape: shape,
              ),
              child: content,
            ),
    );
  }
}