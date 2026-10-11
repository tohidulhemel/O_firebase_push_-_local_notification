import 'dart:async';

import 'package:flutter/material.dart';

import '../core/routes/app_navigator.dart';
import '../models/notification_payload.dart';
import '../models/task_model.dart';
import '../providers/auth_provider.dart';
import '../screens/tasks/add_edit_task_screen.dart';
import 'fcm_service.dart';
import 'firestore_service.dart';
import 'local_notification_service.dart';

/// The single place where notification taps become navigation.
///
/// Three entry points feed it (background tap, app launch by a notification,
/// tap on a local notification). Each tap is queued, and navigation only
/// happens once the Navigator exists and the user is signed in.
class NotificationService {
  NotificationService({
    required FcmService fcm,
    required LocalNotificationService local,
    required FirestoreService firestore,
    required AuthProvider auth,
  })  : _fcm = fcm,
        _local = local,
        _firestore = firestore,
        _auth = auth;

  final FcmService _fcm;
  final LocalNotificationService _local;
  final FirestoreService _firestore;
  final AuthProvider _auth;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  NotificationPayload? _pending;
  bool _isNavigating = false;
  bool _started = false;

  /// Safe to call more than once; only the first call does anything.
  void start() {
    if (_started) return;
    _started = true;

    _subscriptions
      // Foreground FCM messages only display a local notification (see
      // FcmService), so only taps from the background are handled here.
      ..add(_fcm.payloads
          .where((p) => p.source == NotificationSource.background)
          .listen(_enqueue))
      ..add(_local.taps.listen(_enqueue));

    // Navigation may be waiting for the session to be restored or for login.
    _auth.addListener(_onAuthChanged);

    unawaited(_readLaunchNotification());
  }

  /// The notification (if any) that started the app from the terminated state.
  Future<void> _readLaunchNotification() async {
    try {
      final fromFcm = await _fcm.takeInitialPayload();
      final fromLocal = await _local.takeLaunchPayload();
      final launch = fromFcm ?? fromLocal;
      if (launch != null) _enqueue(launch);
    } catch (e) {
      debugPrint('[Navigation] Could not read launch notification: $e');
    }
  }

  void _enqueue(NotificationPayload payload) {
    debugPrint('[Navigation] Queued ${payload.source.name} notification, '
        'taskId=${payload.taskId}');
    _pending = payload; // if several taps arrive, the latest one wins
    unawaited(_tryNavigate());
  }

  void _onAuthChanged() => unawaited(_tryNavigate());

  Future<void> _tryNavigate() async {
    if (_isNavigating) return;
    final payload = _pending;
    if (payload == null) return;

    // Gate 1: the Navigator only exists once MaterialApp has built.
    if (navigatorKey.currentState == null) {
      _retryAfterNextFrame();
      return;
    }
    // Gate 2: wait until Firebase Auth has restored the saved session.
    // The auth listener calls this method again when it is known.
    if (!_auth.isInitialized) return;
    // Gate 3: tasks belong to a signed-in user. Stay queued until login.
    final uid = _auth.user?.uid;
    if (uid == null) {
      debugPrint('[Navigation] Waiting for sign in before opening the task');
      return;
    }

    _isNavigating = true;
    _pending = null;
    try {
      final handled = await _open(payload, uid);
      if (!handled) _pending = payload; // try again when things settle
    } finally {
      _isNavigating = false;
      if (_pending != null && navigatorKey.currentState != null) {
        unawaited(_tryNavigate());
      }
    }
  }

  void _retryAfterNextFrame() {
    final binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) => unawaited(_tryNavigate()));
    binding.ensureVisualUpdate();
  }

  /// Returns false if navigation could not be done yet (and should be retried).
  Future<bool> _open(NotificationPayload payload, String uid) async {
    TaskModel? task;
    String? message;

    final taskId = payload.taskId;
    if (taskId != null) {
      try {
        task = await _firestore.getTask(uid, taskId);
        if (task == null) message = 'That task no longer exists.';
      } on TaskFailure catch (e) {
        message = e.message;
      }
    }

    // The user may have signed out while the task was loading.
    if (_auth.user?.uid != uid) return false;
    final navigator = navigatorKey.currentState;
    if (navigator == null) return false;

    // Always start from the Task List, then open the task on top of it.
    navigator.popUntil((route) => route.isFirst);

    final found = task;
    if (found != null) {
      debugPrint('[Navigation] Opening task ${found.id}');
      unawaited(navigator.push(
        MaterialPageRoute<void>(builder: (_) => AddEditTaskScreen(task: found)),
      ));
    } else {
      debugPrint('[Navigation] Opening Task List (taskId=$taskId, '
          'reason=${message ?? 'no taskId'})');
      if (message != null) _showMessage(message);
    }
    return true;
  }

  void _showMessage(String text) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    ScaffoldMessenger.maybeOf(context)
        ?.showSnackBar(SnackBar(content: Text(text)));
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _auth.removeListener(_onAuthChanged);
  }
}