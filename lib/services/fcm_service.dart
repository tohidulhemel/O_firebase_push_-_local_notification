import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';
import '../models/notification_payload.dart';

/// Runs in its own isolate when a message arrives while the app is in the
/// background or terminated. It must be a top-level function, and it has to
/// initialize Firebase itself because the isolate does not share the app's state.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('[FCM] Background handler: id=${message.messageId} '
      'data=${message.data}');
}

/// Everything about Firebase Cloud Messaging: permission, token, and
/// detecting in which app state a notification was received or opened.
class FcmService {
  FcmService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;
  final StreamController<NotificationPayload> _payloadController =
      StreamController<NotificationPayload>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  bool _initialized = false;
  String? _token;
  AuthorizationStatus? _permissionStatus;
  NotificationPayload? _initialPayload;

  /// Foreground messages and background notification taps.
  Stream<NotificationPayload> get payloads => _payloadController.stream;

  String? get token => _token;
  AuthorizationStatus? get permissionStatus => _permissionStatus;

  /// Returns the notification that launched the app from the terminated state
  /// (or null), and clears it so it is handled only once.
  NotificationPayload? takeInitialPayload() {
    final payload = _initialPayload;
    _initialPayload = null;
    return payload;
  }

  /// Safe to call more than once; only the first call does anything.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _listenForMessages();
    await _readInitialMessage();
    await _requestPermission();
    await _retrieveToken();
  }

  void _listenForMessages() {
    _subscriptions
      ..add(FirebaseMessaging.onMessage
          .listen((m) => _emit(m, NotificationSource.foreground)))
      ..add(FirebaseMessaging.onMessageOpenedApp
          .listen((m) => _emit(m, NotificationSource.background)))
      ..add(_messaging.onTokenRefresh.listen((token) {
        _token = token;
        debugPrint('[FCM] Token refreshed: $token');
      }));
  }

  void _emit(RemoteMessage message, NotificationSource source) {
    final payload = NotificationPayload.fromRemoteMessage(message, source);
    debugPrint('[FCM] ${source.name}: $payload');
    _payloadController.add(payload);
  }

  Future<void> _readInitialMessage() async {
    try {
      final message = await _messaging.getInitialMessage();
      if (message == null) return;
      _initialPayload = NotificationPayload.fromRemoteMessage(
        message,
        NotificationSource.terminated,
      );
      debugPrint('[FCM] terminated: $_initialPayload');
    } catch (e) {
      debugPrint('[FCM] Could not read initial message: $e');
    }
  }

  Future<void> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission();
      _permissionStatus = settings.authorizationStatus;
      debugPrint('[FCM] Permission: ${_permissionStatus!.name}');
      if (_permissionStatus == AuthorizationStatus.denied) {
        debugPrint('[FCM] Notifications are disabled for this app. '
            'Messages still reach the app in the foreground, but the OS '
            'will not show them.');
      }
    } catch (e) {
      debugPrint('[FCM] Permission request failed: $e');
    }
  }

  Future<void> _retrieveToken() async {
    try {
      _token = await _messaging.getToken();
      debugPrint('[FCM] Token: $_token');
    } catch (e) {
      debugPrint('[FCM] Could not get token: $e');
    }
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _payloadController.close();
  }
}