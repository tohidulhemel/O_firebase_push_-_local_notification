import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/task_model.dart';
import '../services/firestore_service.dart';

enum TaskFilter { all, pending, completed }

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._service);

  static const String _notSignedIn = 'Please sign in again.';

  final FirestoreService _service;
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

  /// Called by ChangeNotifierProxyProvider whenever the signed-in user changes.
  /// Starts listening to that user's tasks, or clears everything on logout.
  /// It does not call notifyListeners because it runs during a build.
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

  // The methods below return an error message, or null when they succeed.

  Future<String?> addTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
  }) {
    return _withUser((uid) {
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
      return _service.addTask(uid, task);
    });
  }

  Future<String?> updateTask(TaskModel task) =>
      _withUser((uid) => _service.updateTask(uid, task));

  Future<String?> toggleCompleted(TaskModel task) => _withUser(
        (uid) => _service.setCompleted(uid, task.id, !task.isCompleted),
      );

  Future<String?> deleteTask(TaskModel task) =>
      _withUser((uid) => _service.deleteTask(uid, task.id));

  Future<String?> _withUser(Future<void> Function(String uid) action) async {
    final uid = _uid;
    if (uid == null) return _notSignedIn;
    try {
      await action(uid);
      return null;
    } on TaskFailure catch (e) {
      return e.message;
    }
  }

  /// Pending tasks first (earliest due date first), completed tasks last.
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