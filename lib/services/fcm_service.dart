import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';
import '../models/notification_payload.dart';
import 'local_notification_service.dart';
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('[FCM] Background handler: id=${message.messageId} '
      'data=${message.data}');
}


class FcmService {
  FcmService({
    required LocalNotificationService localNotifications,
    FirebaseMessaging? messaging,
  })  : _localNotifications = localNotifications,
        _messaging = messaging ?? FirebaseMessaging.instance;

  final LocalNotificationService _localNotifications;
  final FirebaseMessaging _messaging;
  final StreamController<NotificationPayload> _payloadController =
      StreamController<NotificationPayload>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions = [];

 
  final Completer<void> _initialMessageRead = Completer<void>();

  bool _initialized = false;
  String? _token;
  AuthorizationStatus? _permissionStatus;
  NotificationPayload? _initialPayload;

  /// Foreground messages and background notification taps.
  Stream<NotificationPayload> get payloads => _payloadController.stream;

  String? get token => _token;
  AuthorizationStatus? get permissionStatus => _permissionStatus;


  Future<NotificationPayload?> takeInitialPayload() async {
    await _initialMessageRead.future;
    final payload = _initialPayload;
    _initialPayload = null;
    return payload;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _listenForMessages();
   
    await _readInitialMessage();
    await _initializeLocalNotifications();
    await _requestPermission();
    await _requestLocalPermission();
    await _retrieveToken();
  }

  void _listenForMessages() {
    _subscriptions
      ..add(FirebaseMessaging.onMessage.listen(_onForegroundMessage))
      ..add(FirebaseMessaging.onMessageOpenedApp
          .listen((m) => _emit(m, NotificationSource.background)))
      ..add(_messaging.onTokenRefresh.listen((token) {
        _token = token;
        debugPrint('[FCM] Token refreshed: $token');
      }));
  }

  /// FCM never draws a notification while the app is open, so we draw it.
  void _onForegroundMessage(RemoteMessage message) {
    final payload = _emit(message, NotificationSource.foreground);
    if (payload.title == null && payload.body == null) {
      debugPrint('[FCM] Foreground message has no title or body, '
          'so no notification is shown.');
      return;
    }
    unawaited(_localNotifications.show(payload));
  }

  NotificationPayload _emit(RemoteMessage message, NotificationSource source) {
    final payload = NotificationPayload.fromRemoteMessage(message, source);
    debugPrint('[FCM] ${source.name}: $payload');
    _payloadController.add(payload);
    return payload;
  }

  Future<void> _readInitialMessage() async {
    try {
      final message = await _messaging.getInitialMessage();
      if (message != null) {
        _initialPayload = NotificationPayload.fromRemoteMessage(
          message,
          NotificationSource.terminated,
        );
        debugPrint('[FCM] terminated: $_initialPayload');
      }
    } catch (e) {
      debugPrint('[FCM] Could not read initial message: $e');
    } finally {
      _initialMessageRead.complete();
    }
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      await _localNotifications.initialize();
    } catch (e) {
      debugPrint('[FCM] Local notifications failed to initialize: $e');
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

  /// Runs after the FCM request, so it only asks if that did not grant it.
  Future<void> _requestLocalPermission() async {
    try {
      final granted = await _localNotifications.requestPermission();
      debugPrint('[FCM] Local notifications allowed: $granted');
    } catch (e) {
      debugPrint('[FCM] Local permission check failed: $e');
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