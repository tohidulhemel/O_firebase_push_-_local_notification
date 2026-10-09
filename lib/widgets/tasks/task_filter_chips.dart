import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/task_provider.dart';

/// All / Pending / Completed chips with live counts.
class TaskFilterChips extends StatelessWidget {
  const TaskFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            count: tasks.totalCount,
            active: tasks.filter == TaskFilter.all,
            onTap: () => tasks.setFilter(TaskFilter.all),
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: 'Pending',
            count: tasks.pendingCount,
            active: tasks.filter == TaskFilter.pending,
            onTap: () => tasks.setFilter(TaskFilter.pending),
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: 'Completed',
            count: tasks.completedCount,
            active: tasks.filter == TaskFilter.completed,
            onTap: () => tasks.setFilter(TaskFilter.completed),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = active ? Colors.white : AppColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.dark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: active ? AppColors.dark : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: active
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.chip.copyWith(
                  color: active ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}