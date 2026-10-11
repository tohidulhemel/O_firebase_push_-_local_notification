import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/constants/app_constants.dart';
import '../models/notification_payload.dart';

/// Shows notifications drawn by the app itself and reports when they are tapped.
class LocalNotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// Also referenced in AndroidManifest.xml as the default FCM channel.
  static const String channelId = 'high_importance_channel';
  static const String _channelName = 'Task notifications';
  static const String _channelDescription =
      'Reminders and updates about your tasks.';

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
    ),
  );

  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<NotificationPayload> _tapController =
      StreamController<NotificationPayload>.broadcast();
  Future<void>? _initFuture;

  /// Emits when the user taps a notification created by [show] while the
  /// app is running.
  Stream<NotificationPayload> get taps => _tapController.stream;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  /// Safe to call many times; the setup only runs once.
  Future<void> initialize() => _initFuture ??= _initialize();

  Future<void> _initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // iOS permission is requested by FCM, not here.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onTap,
    );

    // Heads-up (pop-up) notifications need a high-importance channel.
    await _android?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
      ),
    );
    debugPrint('[LocalNotification] Initialized, channel "$channelId" ready');
  }

  /// Android 13+ runtime permission. Does nothing if it is already granted,
  /// so it never shows a second dialog after FCM has asked.
  Future<bool> requestPermission() async {
    await initialize();
    final android = _android;
    if (android == null) return true;
    if (await android.areNotificationsEnabled() ?? false) return true;
    return await android.requestNotificationsPermission() ?? false;
  }

  /// Displays [payload] as a visible notification and stores `type` and
  /// `taskId` inside it for the tap callback.
  Future<void> show(NotificationPayload payload) async {
    try {
      await initialize();
      final id = _notificationId(payload);
      await _plugin.show(
        id: id,
        title: payload.title ?? AppConstants.appName,
        body: payload.body ?? 'You have a new notification.',
        notificationDetails: _details,
        payload: payload.toJsonString(),
      );
      debugPrint('[LocalNotification] Shown id=$id taskId=${payload.taskId}');
    } catch (e) {
      debugPrint('[LocalNotification] Could not show notification: $e');
    }
  }

  /// If the app was started by tapping one of our local notifications, returns
  /// its payload. The tap callback does not fire for the tap that launches the
  /// app, so the launch details are read separately. Call once at startup.
  Future<NotificationPayload?> takeLaunchPayload() async {
    await initialize();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    final raw = details.notificationResponse?.payload;
    if (raw == null || raw.isEmpty) return null;
    final payload = NotificationPayload.fromJsonString(
      raw,
      source: NotificationSource.localTap,
    );
    debugPrint('[LocalNotification] App launched by: $payload');
    return payload;
  }

  void _onTap(NotificationResponse response) {
    final raw = response.payload;
    if (raw == null || raw.isEmpty) {
      debugPrint('[LocalNotification] Tapped, but it carries no payload');
      return;
    }
    final payload = NotificationPayload.fromJsonString(
      raw,
      source: NotificationSource.localTap,
    );
    if (payload == null) {
      debugPrint('[LocalNotification] Tapped, but payload is invalid: $raw');
      return;
    }
    debugPrint('[LocalNotification] Tapped: $payload');
    _tapController.add(payload);
  }

  /// Android notification IDs must fit in a 32-bit integer, so a raw
  /// millisecond timestamp would be rejected. The ID is built from a stable
  /// hash instead: the same task always maps to the same ID (a new reminder
  /// replaces the old one), and different tasks get different IDs.
  int _notificationId(NotificationPayload payload) {
    final key = payload.taskId ??
        payload.messageId ??
        DateTime.now().microsecondsSinceEpoch.toString();
    var hash = 0x811C9DC5; // FNV-1a hash, kept within 31 bits
    for (final unit in key.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash;
  }

  void dispose() {
    _tapController.close();
  }
}