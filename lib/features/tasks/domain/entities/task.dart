import 'package:equatable/equatable.dart';
import 'subtask.dart';
import 'task_priority.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String category;
  final TaskPriority priority;
  final DateTime? dueDate;
  final String? dueTime;
  final String? timeRange;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final List<SubTask> subtasks;
  final List<String> tags;
  final bool isPinned;
  final bool hasReminder;
  final String status; // 'On going', 'In Process', 'Completed', 'Canceled'
  final double? customProgress; // 0.0 to 1.0 (e.g. 0.4 for 40%)
  final String? assigneeName;
  final String? assigneeAvatar;
  final String? colorHex;

  const Task({
    required this.id,
    required this.title,
    this.subtitle = 'Digital Product Design',
    this.description = '',
    this.category = 'Personal',
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.dueTime,
    this.timeRange,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    this.subtasks = const [],
    this.tags = const [],
    this.isPinned = false,
    this.hasReminder = false,
    this.status = 'In Process',
    this.customProgress,
    this.assigneeName,
    this.assigneeAvatar,
    this.colorHex,
  });

  bool get hasSubtasks => subtasks.isNotEmpty;

  int get completedSubtasksCount =>
      subtasks.where((s) => s.isCompleted).length;

  double get subtaskProgress {
    if (customProgress != null) return customProgress!;
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    return completedSubtasksCount / subtasks.length;
  }

  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return taskDate.isBefore(today);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate!.year == tomorrow.year &&
        dueDate!.month == tomorrow.month &&
        dueDate!.day == tomorrow.day;
  }

  Task copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    String? category,
    TaskPriority? priority,
    DateTime? dueDate,
    String? dueTime,
    String? timeRange,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    List<SubTask>? subtasks,
    List<String>? tags,
    bool? isPinned,
    bool? hasReminder,
    String? status,
    double? customProgress,
    String? assigneeName,
    String? assigneeAvatar,
    String? colorHex,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      timeRange: timeRange ?? this.timeRange,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      subtasks: subtasks ?? this.subtasks,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      hasReminder: hasReminder ?? this.hasReminder,
      status: status ?? this.status,
      customProgress: customProgress ?? this.customProgress,
      assigneeName: assigneeName ?? this.assigneeName,
      assigneeAvatar: assigneeAvatar ?? this.assigneeAvatar,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        description,
        category,
        priority,
        dueDate,
        dueTime,
        timeRange,
        isCompleted,
        completedAt,
        createdAt,
        subtasks,
        tags,
        isPinned,
        hasReminder,
        status,
        customProgress,
        assigneeName,
        assigneeAvatar,
        colorHex,
      ];
}
