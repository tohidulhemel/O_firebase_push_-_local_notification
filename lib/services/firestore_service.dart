import 'dart:async';

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


  static const Duration _writeTimeout = Duration(seconds: 5);
  static const Duration _readTimeout = Duration(seconds: 5);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _tasks(String uid) =>
      _db.collection('users').doc(uid).collection('tasks');

  Stream<List<TaskModel>> watchTasks(String uid) {
    return _tasks(uid).snapshots().map(
          (snapshot) => snapshot.docs.map(TaskModel.fromFirestore).toList(),
        );
  }

  /// Loads one task. Returns null if it does not exist (or the id is not a
  /// valid document id); throws [TaskFailure] if it could not be read.
  Future<TaskModel?> getTask(String uid, String taskId) async {
    try {
      final doc = await _tasks(uid).doc(taskId).get().timeout(_readTimeout);
      return doc.exists ? TaskModel.fromFirestore(doc) : null;
    } on ArgumentError {
      return null;
    } on TimeoutException {
      throw const TaskFailure(
        'Could not reach the server. Check your internet connection.',
      );
    } on FirebaseException catch (e) {
      debugPrint('Firestore error: ${e.code}');
      throw TaskFailure(_messageFor(e));
    }
  }

  /// Creates a task and returns it with its Firestore document ID.
  ///
  /// The returned task is available only after the write completes, so callers
  /// can safely use its ID in a local notification payload.
  Future<TaskModel> addTask(String uid, TaskModel task) async {
    final ref = _tasks(uid).doc();
    final createdTask = task.copyWith(id: ref.id);
    await _write(() => ref.set(createdTask.toCreateMap()));
    return createdTask;
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
      
      await action().timeout(_writeTimeout);
    } on TimeoutException {
      throw const TaskFailure(
        'Saving took too long. Check your connection and try again.',
      );
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