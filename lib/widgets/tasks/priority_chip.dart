import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../models/task_model.dart';
import 'priority_style.dart';

class PriorityDot extends StatelessWidget {
  const PriorityDot({super.key, required this.color, this.size = 7});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Small pill used on task cards and in the delete dialog.
class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority, this.label});

  final TaskPriority priority;

  /// Overrides the text, e.g. "High Priority".
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: priority.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PriorityDot(color: priority.dotColor),
          const SizedBox(width: 6),
          Text(
            label ?? priority.label,
            style: AppTextStyles.chip.copyWith(color: priority.textColor),
          ),
        ],
      ),
    );
  }
}