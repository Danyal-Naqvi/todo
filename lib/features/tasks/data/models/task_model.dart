import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_priority.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    super.subtitle,
    super.description,
    super.category,
    super.priority,
    super.dueDate,
    super.dueTime,
    super.timeRange,
    super.isCompleted,
    super.completedAt,
    required super.createdAt,
    super.subtasks,
    super.tags,
    super.isPinned,
    super.hasReminder,
    super.status,
    super.customProgress,
    super.assigneeName,
    super.assigneeAvatar,
    super.colorHex,
  });

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      subtitle: task.subtitle,
      description: task.description,
      category: task.category,
      priority: task.priority,
      dueDate: task.dueDate,
      dueTime: task.dueTime,
      timeRange: task.timeRange,
      isCompleted: task.isCompleted,
      completedAt: task.completedAt,
      createdAt: task.createdAt,
      subtasks: task.subtasks,
      tags: task.tags,
      isPinned: task.isPinned,
      hasReminder: task.hasReminder,
      status: task.status,
      customProgress: task.customProgress,
      assigneeName: task.assigneeName,
      assigneeAvatar: task.assigneeAvatar,
      colorHex: task.colorHex,
    );
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime parseDate(dynamic value, DateTime fallback) {
      if (value == null) return fallback;
      if (value is Timestamp) return value.toDate();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) {
        return DateTime.tryParse(value) ?? fallback;
      }
      return fallback;
    }

    DateTime? parseNullableDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    final rawSubtasks = map['subtasks'];
    List<SubTask> subtaskList = [];
    if (rawSubtasks is List) {
      subtaskList = rawSubtasks
          .map((item) => SubTask.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }

    final rawTags = map['tags'];
    List<String> tagList = [];
    if (rawTags is List) {
      tagList = rawTags.map((t) => t.toString()).toList();
    }

    return TaskModel(
      id: docId ?? (map['id'] as String? ?? ''),
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? 'Digital Product Design',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Personal',
      priority: TaskPriority.fromString(map['priority'] as String?),
      dueDate: parseNullableDate(map['dueDate']),
      dueTime: map['dueTime'] as String?,
      timeRange: map['timeRange'] as String?,
      isCompleted: map['isCompleted'] as bool? ?? false,
      completedAt: parseNullableDate(map['completedAt']),
      createdAt: parseDate(map['createdAt'], DateTime.now()),
      subtasks: subtaskList,
      tags: tagList,
      isPinned: map['isPinned'] as bool? ?? false,
      hasReminder: map['hasReminder'] as bool? ?? false,
      status: map['status'] as String? ?? 'In Process',
      customProgress: (map['customProgress'] as num?)?.toDouble(),
      assigneeName: map['assigneeName'] as String?,
      assigneeAvatar: map['assigneeAvatar'] as String?,
      colorHex: map['colorHex'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'category': category,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'dueTime': dueTime,
      'timeRange': timeRange,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
      'tags': tags,
      'isPinned': isPinned,
      'hasReminder': hasReminder,
      'status': status,
      'customProgress': customProgress,
      'assigneeName': assigneeName,
      'assigneeAvatar': assigneeAvatar,
      'colorHex': colorHex,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'category': category,
      'priority': priority.name,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'dueTime': dueTime,
      'timeRange': timeRange,
      'isCompleted': isCompleted,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
      'tags': tags,
      'isPinned': isPinned,
      'hasReminder': hasReminder,
      'status': status,
      'customProgress': customProgress,
      'assigneeName': assigneeName,
      'assigneeAvatar': assigneeAvatar,
      'colorHex': colorHex,
    };
  }
}
