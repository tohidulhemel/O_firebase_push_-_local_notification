import 'package:firebase_push_local_notification/core/utils/date_formatteres.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/task_model.dart';
import 'priority_chip.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final done = task.isCompleted;

    return Opacity(
      opacity: done ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CheckCircle(done: done, onTap: onToggle),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PriorityChip(priority: task.priority),
                      if (done) ...[
                        const SizedBox(width: 8),
                        const _DoneChip(),
                      ],
                      const Spacer(),
                      _IconAction(icon: Icons.edit_outlined, onTap: onEdit),
                      _IconAction(icon: Icons.delete_outline, onTap: onDelete),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.title,
                    style: AppTextStyles.cardTitle.copyWith(
                      decoration:
                          done ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body,
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  Row(
                    children: [
                      Icon(
                        done
                            ? Icons.check_circle_outline
                            : Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Due ${DateFormatters.short(task.dueDate)}',
                        style: AppTextStyles.body.copyWith(fontSize: 13),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormatters.short(task.createdAt),
                        style: AppTextStyles.caption.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.done, required this.onTap});

  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? const Color(0xFF475569) : Colors.transparent,
          border: Border.all(
            color: done ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
            width: 2,
          ),
        ),
        child: done
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : null,
      ),
    );
  }
}

class _DoneChip extends StatelessWidget {
  const _DoneChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.doneBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Done',
        style: AppTextStyles.chip.copyWith(color: AppColors.doneText),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: AppColors.textHint),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 32),
    );
  }
}