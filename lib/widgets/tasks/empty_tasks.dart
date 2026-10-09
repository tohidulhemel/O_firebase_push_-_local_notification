import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/task_provider.dart';

class EmptyTasks extends StatelessWidget {
  const EmptyTasks({super.key, required this.filter});

  final TaskFilter filter;

  @override
  Widget build(BuildContext context) {
    final (title, message) = switch (filter) {
      TaskFilter.all => ('No tasks yet', 'Tap "New Task" to add your first one.'),
      TaskFilter.pending => ('Nothing pending', 'You are all caught up.'),
      TaskFilter.completed => (
          'No completed tasks',
          'Tasks you finish will show up here.',
        ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceMuted,
              ),
              child: const Icon(
                Icons.checklist_rounded,
                size: 32,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 18)),
            const SizedBox(height: 6),
            Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}