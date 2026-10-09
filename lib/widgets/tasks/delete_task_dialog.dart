import 'package:firebase_push_local_notification/core/utils/date_formatteres.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/task_model.dart';
import '../common/app_button.dart';
import 'priority_chip.dart';

/// Returns true if the user confirmed the deletion.
Future<bool?> showDeleteTaskDialog(BuildContext context, TaskModel task) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _DeleteTaskDialog(task: task),
  );
}

class _DeleteTaskDialog extends StatelessWidget {
  const _DeleteTaskDialog({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete Task?',
              style: AppTextStyles.heading.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to remove this task?\n'
              'This action cannot be undone.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (task.course != null)
                        Text(
                          task.course!,
                          style: AppTextStyles.link.copyWith(fontSize: 15),
                        ),
                      const Spacer(),
                      PriorityChip(
                        priority: task.priority,
                        label: '${task.priority.label} Priority',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task.title,
                    style: AppTextStyles.input.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Due ${DateFormatters.full(task.dueDate)}',
                        style: AppTextStyles.caption.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Delete Task',
              backgroundColor: AppColors.error,
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: AppTextStyles.body.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}