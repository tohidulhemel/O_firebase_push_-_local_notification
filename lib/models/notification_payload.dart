import 'package:firebase_messaging/firebase_messaging.dart';

/// When the notification was seen:
/// - foreground: a message arrived while the app was open
/// - background: the user tapped a notification while the app was in the background
/// - terminated: the user tapped a notification that started the app
enum NotificationSource { foreground, background, terminated }

class NotificationPayload {
  const NotificationPayload({
    required this.source,
    this.type,
    this.taskId,
    this.title,
    this.body,
    this.data = const {},
  });

  final NotificationSource source;
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
      type: data['type'],
      taskId: (taskId == null || taskId.isEmpty) ? null : taskId,
      title: message.notification?.title ?? data['title'],
      body: message.notification?.body ?? data['body'],
      data: data,
    );
  }

  @override
  String toString() => 'NotificationPayload(source: ${source.name}, '
      'type: $type, taskId: $taskId, title: $title, body: $body)';
}