import 'package:firebase_push_local_notification/core/utils/date_formatteres.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/common/error_message.dart';
import '../../widgets/tasks/delete_task_dialog.dart';
import '../../widgets/tasks/empty_tasks.dart';
import '../../widgets/tasks/task_card.dart';
import '../../widgets/tasks/task_filter_chips.dart';
import 'add_edit_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  void _openForm(BuildContext context, [TaskModel? task]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditTaskScreen(task: task)),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggle(BuildContext context, TaskModel task) async {
    final error = await context.read<TaskProvider>().toggleCompleted(task);
    if (error != null && context.mounted) _showError(context, error);
  }

  Future<void> _delete(BuildContext context, TaskModel task) async {
    final confirmed = await showDeleteTaskDialog(context, task);
    if (confirmed != true || !context.mounted) return;
    final error = await context.read<TaskProvider>().deleteTask(task);
    if (error != null && context.mounted) _showError(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: Text(
          'New Task',
          style: AppTextStyles.button.copyWith(fontSize: 15),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Header(totalCount: tasks.totalCount),
            const TaskFilterChips(),
            Expanded(child: _Body(tasks: tasks, onEdit: _openForm, onToggle: _toggle, onDelete: _delete)),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.tasks,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final TaskProvider tasks;
  final void Function(BuildContext, TaskModel) onEdit;
  final Future<void> Function(BuildContext, TaskModel) onToggle;
  final Future<void> Function(BuildContext, TaskModel) onDelete;

  @override
  Widget build(BuildContext context) {
    if (tasks.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (tasks.loadError != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: ErrorMessage(message: tasks.loadError!),
      );
    }

    final visible = tasks.visibleTasks;
    if (visible.isEmpty) return EmptyTasks(filter: tasks.filter);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: visible.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = visible[index];
        return TaskCard(
          key: ValueKey(task.id),
          task: task,
          onToggle: () => onToggle(context, task),
          onEdit: () => onEdit(context, task),
          onDelete: () => onDelete(context, task),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Tasks', style: AppTextStyles.heading.copyWith(fontSize: 24)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$totalCount TOTAL',
                        style: AppTextStyles.chip.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Today • ${DateFormatters.header(DateTime.now())}',
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Account',
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (value) {
              if (value == 'logout') auth.signOut();
            },
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  auth.user?.email ?? 'Signed in',
                  style: AppTextStyles.body,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 18),
                    const SizedBox(width: 10),
                    Text('Log out', style: AppTextStyles.input.copyWith(fontSize: 15)),
                  ],
                ),
              ),
            ],
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}