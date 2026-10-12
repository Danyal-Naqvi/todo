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
  final bool isAlarmEnabled;
  final int alarmOffsetMinutes; // 0 = at start time, 5 = 5m before, etc.
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
    this.isAlarmEnabled = false,
    this.alarmOffsetMinutes = 0,
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

  /// Parses hour and minute from strings like "10:45 am", "10.45 am", "14:00"
  static (int, int)? parseTimeString(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final clean = raw.toLowerCase().replaceAll('.', ':');
    final regex = RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)?');
    final match = regex.firstMatch(clean);
    if (match != null) {
      var hour = int.tryParse(match.group(1) ?? '');
      final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
      final period = match.group(3);
      if (hour != null) {
        if (period == 'pm' && hour < 12) hour += 12;
        if (period == 'am' && hour == 12) hour = 0;
        return (hour, minute);
      }
    }
    return null;
  }

  /// Combines [dueDate] with [dueTime] or [timeRange] to get the exact start DateTime
  DateTime? get startDateTime {
    final baseDate = dueDate ?? DateTime.now();
    (int, int)? timeParsed;
    if (dueTime != null && dueTime!.trim().isNotEmpty) {
      timeParsed = parseTimeString(dueTime);
    }
    if (timeParsed == null && timeRange != null && timeRange!.trim().isNotEmpty) {
      final startPart = timeRange!.split('-').first.trim();
      timeParsed = parseTimeString(startPart);
    }
    if (timeParsed != null) {
      return DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        timeParsed.$1,
        timeParsed.$2,
      );
    }
    if (dueDate != null && (dueDate!.hour != 0 || dueDate!.minute != 0)) {
      return dueDate;
    }
    if (dueDate != null) {
      return DateTime(baseDate.year, baseDate.month, baseDate.day, 9, 0);
    }
    return null;
  }

  /// Exact scheduled time for the alarm (accounting for alarmOffsetMinutes)
  DateTime? get scheduledAlarmTime {
    final start = startDateTime;
    if (start == null) return null;
    return start.subtract(Duration(minutes: alarmOffsetMinutes));
  }

  /// Whether this task has an active, actionable start alarm
  bool get hasActiveAlarm {
    final enabled = isAlarmEnabled || hasReminder;
    if (!enabled) return false;
    if (isCompleted) return false;
    final s = status.trim().toLowerCase();
    if (s == 'completed' || s == 'canceled' || s == 'cancelled') return false;
    return true;
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
    bool? isAlarmEnabled,
    int? alarmOffsetMinutes,
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
      isAlarmEnabled: isAlarmEnabled ?? this.isAlarmEnabled,
      alarmOffsetMinutes: alarmOffsetMinutes ?? this.alarmOffsetMinutes,
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
        isAlarmEnabled,
        alarmOffsetMinutes,
        status,
        customProgress,
        assigneeName,
        assigneeAvatar,
        colorHex,
      ];
}
