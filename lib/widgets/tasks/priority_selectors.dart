import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/task_model.dart';
import 'priority_chip.dart';
import 'priority_style.dart';

/// Three bordered chips with a colored dot (New Task screen).
class PriorityChipSelector extends StatelessWidget {
  const PriorityChipSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TaskPriority selected;
  final ValueChanged<TaskPriority> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final p in TaskPriority.values) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p == selected ? p.backgroundColor : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: p == selected ? p.borderColor : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PriorityDot(color: p.dotColor, size: 8),
                    const SizedBox(width: 8),
                    Text(
                      p.label,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight:
                            p == selected ? FontWeight.w700 : FontWeight.w500,
                        color: p == selected
                            ? p.textColor
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (p != TaskPriority.values.last) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

/// Grey track with a white sliding pill (Edit Task screen).
class PrioritySegmentedControl extends StatelessWidget {
  const PrioritySegmentedControl({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TaskPriority selected;
  final ValueChanged<TaskPriority> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final p in TaskPriority.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p == selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: p == selected
                        ? const [
                            BoxShadow(
                              color: Color(0x140F172A),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    p.label,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 15,
                      fontWeight:
                          p == selected ? FontWeight.w700 : FontWeight.w500,
                      color: p == selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}