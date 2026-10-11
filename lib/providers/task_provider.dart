import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/notification_payload.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';
import '../services/local_notification_service.dart';

enum TaskFilter { all, pending, completed }

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._service, this._localNotifications);

  static const String _notSignedIn = 'Please sign in again.';

  final FirestoreService _service;
  final LocalNotificationService _localNotifications;
  StreamSubscription<List<TaskModel>>? _subscription;

  String? _uid;
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _loadError;
  TaskFilter _filter = TaskFilter.all;

  bool get isLoading => _isLoading;
  String? get loadError => _loadError;
  TaskFilter get filter => _filter;

  int get totalCount => _tasks.length;
  int get pendingCount => _tasks.where((t) => !t.isCompleted).length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;

  List<TaskModel> get visibleTasks {
    switch (_filter) {
      case TaskFilter.all:
        return _tasks;
      case TaskFilter.pending:
        return _tasks.where((t) => !t.isCompleted).toList();
      case TaskFilter.completed:
        return _tasks.where((t) => t.isCompleted).toList();
    }
  }


  void updateUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _subscription?.cancel();
    _subscription = null;
    _tasks = [];
    _loadError = null;
    _filter = TaskFilter.all;
    _isLoading = uid != null;

    if (uid == null) return;
    _subscription = _service.watchTasks(uid).listen(
      (tasks) {
        _tasks = [...tasks]..sort(_compare);
        _isLoading = false;
        _loadError = null;
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('Task stream error: $error');
        _isLoading = false;
        _loadError = 'Could not load your tasks. Check your connection.';
        notifyListeners();
      },
    );
  }

  void setFilter(TaskFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }


  Future<String?> addTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
  }) {
    return _withUser((uid) async {
      final task = TaskModel(
        id: '',
        title: title.trim(),
        description: description.trim(),
        dueDate: dueDate,
        priority: priority,
        isCompleted: false,
        createdAt: DateTime.now(),
        userId: uid,
      );
      final createdTask = await _service.addTask(uid, task);

      await _showTaskNotification(
        type: NotificationPayload.typeTaskCreated,
        taskId: createdTask.id,
        title: 'Task Created',
        body: 'Your task "${createdTask.title}" has been added successfully.',
      );
    });
  }

  Future<String?> updateTask(TaskModel task) => _withUser((uid) async {
        TaskModel? previousTask;
        for (final existing in _tasks) {
          if (existing.id == task.id) {
            previousTask = existing;
            break;
          }
        }

        await _service.updateTask(uid, task);

        if (previousTask != null &&
            previousTask.isCompleted != task.isCompleted) {
          final completed = task.isCompleted;
          await _showTaskNotification(
            type: completed
                ? NotificationPayload.typeTaskCompleted
                : NotificationPayload.typeTaskReopened,
            taskId: task.id,
            title: completed ? 'Task Completed' : 'Task Reopened',
            body: completed
                ? 'Great job! "${task.title}" has been marked as completed.'
                : '"${task.title}" has been marked as pending.',
          );
        } else {
          await _showTaskNotification(
            type: NotificationPayload.typeTaskUpdated,
            taskId: task.id,
            title: 'Task Updated',
            body: 'Your task "${task.title}" has been updated successfully.',
          );
        }
      });

  Future<String?> toggleCompleted(TaskModel task) => _withUser((uid) async {
        final willBeCompleted = !task.isCompleted;
        await _service.setCompleted(uid, task.id, willBeCompleted);

        if (willBeCompleted) {
          await _showTaskNotification(
            type: NotificationPayload.typeTaskCompleted,
            taskId: task.id,
            title: 'Task Completed',
            body: 'Great job! "${task.title}" has been marked as completed.',
          );
        } else {
          await _showTaskNotification(
            type: NotificationPayload.typeTaskReopened,
            taskId: task.id,
            title: 'Task Reopened',
            body: '"${task.title}" has been marked as pending.',
          );
        }
      });

  Future<String?> deleteTask(TaskModel task) => _withUser((uid) async {
        await _service.deleteTask(uid, task.id);
        await _showTaskNotification(
          type: NotificationPayload.typeTaskDeleted,
          taskId: task.id,
          title: 'Task Deleted',
          body: '"${task.title}" has been deleted successfully.',
        );
      });

  Future<void> _showTaskNotification({
    required String type,
    required String taskId,
    required String title,
    required String body,
  }) {
    return _localNotifications.show(
      NotificationPayload(
        source: NotificationSource.foreground,
        type: type,
        taskId: taskId,
        title: title,
        body: body,
      ),
    );
  }

  Future<String?> _withUser(Future<void> Function(String uid) action) async {
    final uid = _uid;
    if (uid == null) return _notSignedIn;
    try {
      await action(uid);
      return null;
    } on TaskFailure catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('Task operation failed: $e');
      return 'Something went wrong. Please try again.';
    }
  }

  int _compare(TaskModel a, TaskModel b) {
    if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
    final byDue = a.dueDate.compareTo(b.dueDate);
    return byDue != 0 ? byDue : b.createdAt.compareTo(a.createdAt);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
