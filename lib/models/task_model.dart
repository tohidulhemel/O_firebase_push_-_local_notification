import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority {
  low('Low'),
  medium('Medium'),
  high('High');

  const TaskPriority(this.label);
  final String label;
}

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
    required this.userId,
    this.course,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime createdAt;
  final String userId;
  final String? course;

  /// Firestore -> Dart. Missing or null fields fall back to safe defaults.
  factory TaskModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    // createdAt is null for a moment after a local write, until the server
    // timestamp arrives, so fall back to "now".
    final createdAt =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    return TaskModel(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? createdAt,
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      isCompleted: (data['isCompleted'] as bool?) ?? false,
      createdAt: createdAt,
      userId: (data['userId'] as String?) ?? '',
      course: data['course'] as String?,
    );
  }

  /// Dart -> Firestore for a new document (createdAt is set by the server).
  Map<String, dynamic> toCreateMap() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': Timestamp.fromDate(dueDate),
        'priority': priority.name,
        'isCompleted': isCompleted,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': userId,
        'course': course,
      };

  /// Fields that may change after creation (id, userId, createdAt never do).
  Map<String, dynamic> toUpdateMap() => {
        'title': title,
        'description': description,
        'dueDate': Timestamp.fromDate(dueDate),
        'priority': priority.name,
        'isCompleted': isCompleted,
        'course': course,
      };

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    String? course,
    bool clearCourse = false,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      userId: userId,
      course: clearCourse ? null : (course ?? this.course),
    );
  }
}