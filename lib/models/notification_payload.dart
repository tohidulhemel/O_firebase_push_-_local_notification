import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

/// Where the notification was seen:
/// - foreground: an FCM message arrived while the app was open
/// - background: the user tapped an FCM notification while the app was in the background
/// - terminated: the user tapped an FCM notification that started the app
/// - localTap: the user tapped a local notification created by this app
enum NotificationSource { foreground, background, terminated, localTap }

class NotificationPayload {
  const NotificationPayload({
    required this.source,
    this.messageId,
    this.type,
    this.taskId,
    this.title,
    this.body,
    this.data = const {},
  });

  final NotificationSource source;
  final String? messageId;
  final String? type;
  final String? taskId;
  final String? title;
  final String? body;
  final Map<String, String> data;

  /// True when the notification points at a specific task.
  bool get hasTask => taskId != null;

  /// Expected data payload: {"type": "task", "taskId": "<document id>"}.
  /// Missing or empty values are treated as absent.
  factory NotificationPayload.fromRemoteMessage(
    RemoteMessage message,
    NotificationSource source,
  ) {
    final data = message.data.map((k, v) => MapEntry(k, v.toString()));
    final taskId = data['taskId']?.trim();

    return NotificationPayload(
      source: source,
      messageId: message.messageId,
      type: data['type'],
      taskId: (taskId == null || taskId.isEmpty) ? null : taskId,
      title: message.notification?.title ?? data['title'],
      body: message.notification?.body ?? data['body'],
      data: data,
    );
  }

  /// Rebuilds the payload from the JSON string stored inside a local
  /// notification. Returns null if the string is not valid.
  static NotificationPayload? fromJsonString(
    String raw, {
    required NotificationSource source,
  }) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final taskId = (decoded['taskId'] as String?)?.trim();
      return NotificationPayload(
        source: source,
        type: decoded['type'] as String?,
        taskId: (taskId == null || taskId.isEmpty) ? null : taskId,
      );
    } catch (_) {
      return null;
    }
  }

  /// The string saved as the local notification's payload, so `type` and
  /// `taskId` survive until the user taps it.
  String toJsonString() => jsonEncode({
        if (type != null) 'type': type,
        if (taskId != null) 'taskId': taskId,
      });

  @override
  String toString() => 'NotificationPayload(source: ${source.name}, '
      'type: $type, taskId: $taskId, title: $title, body: $body)';
}