import 'package:firebase_push_local_notification/core/utils/date_formatteres.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../common/field_label.dart';

/// Tappable date box that looks like the Figma input (opens a date picker).
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.uppercaseLabel = true,
    this.iconFirst = false,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;
  final bool uppercaseLabel;

  /// Edit Task shows the calendar icon before the date, New Task after it.
  final bool iconFirst;

  @override
  Widget build(BuildContext context) {
    const icon = Icon(
      Icons.calendar_today_outlined,
      size: 20,
      color: AppColors.textSecondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label, uppercase: uppercaseLabel),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: AppSizes.buttonHeight,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radius),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                if (iconFirst) ...[icon, const SizedBox(width: 10)],
                Expanded(
                  child: Text(
                    DateFormatters.form(value),
                    style: AppTextStyles.input,
                  ),
                ),
                if (!iconFirst) icon,
              ],
            ),
          ),
        ),
      ],
    );
  }
}