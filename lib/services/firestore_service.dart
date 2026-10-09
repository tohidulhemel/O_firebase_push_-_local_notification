import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/task_model.dart';

/// A readable error that is safe to show directly in the UI.
class TaskFailure implements Exception {
  const TaskFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

/// All Firestore access for tasks: users/{uid}/tasks/{taskId}.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Firestore queues writes made offline and only confirms them once the
  /// server answers. We stop waiting after this long so the UI never hangs.
  static const Duration _writeTimeout = Duration(seconds: 5);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _tasks(String uid) =>
      _db.collection('users').doc(uid).collection('tasks');

  Stream<List<TaskModel>> watchTasks(String uid) {
    return _tasks(uid).snapshots().map(
          (snapshot) => snapshot.docs.map(TaskModel.fromFirestore).toList(),
        );
  }

  Future<void> addTask(String uid, TaskModel task) {
    final ref = _tasks(uid).doc();
    return _write(() => ref.set(task.copyWith(id: ref.id).toCreateMap()));
  }

  Future<void> updateTask(String uid, TaskModel task) {
    return _write(() => _tasks(uid).doc(task.id).update(task.toUpdateMap()));
  }

  Future<void> setCompleted(String uid, String taskId, bool isCompleted) {
    return _write(
      () => _tasks(uid).doc(taskId).update({'isCompleted': isCompleted}),
    );
  }

  Future<void> deleteTask(String uid, String taskId) {
    return _write(() => _tasks(uid).doc(taskId).delete());
  }

  Future<void> _write(Future<void> Function() action) async {
    try {
      await action().timeout(_writeTimeout, onTimeout: () {});
    } on FirebaseException catch (e) {
      debugPrint('Firestore error: ${e.code}');
      throw TaskFailure(_messageFor(e));
    }
  }

  String _messageFor(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return "You don't have permission to do that. Try signing in again.";
      case 'unavailable':
      case 'deadline-exceeded':
        return 'Could not reach the server. Check your internet connection.';
      case 'not-found':
        return 'This task no longer exists.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}