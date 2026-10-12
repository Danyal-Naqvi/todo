import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/task.dart';
import 'custom_checkbox.dart';
import 'priority_badge.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final ValueChanged<bool> onToggleComplete;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onTogglePin,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = task.priority.color;

    return Dismissible(
      key: ValueKey('task_${task.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        decoration: BoxDecoration(
          color: AppColors.priorityLow.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'Toggle Done',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.priorityUrgent.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggleComplete(!task.isCompleted);
          return false; // Don't dismiss, just toggle
        } else {
          // Show confirmation before deleting
          return await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor:
                      isDark ? AppColors.darkCard : Colors.white,
                  title: const Text('Delete Task?'),
                  content: Text(
                    'Are you sure you want to delete "${task.title}"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.priorityUrgent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ) ??
              false;
        }
      },
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: task.isCompleted ? 0.65 : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  // Left priority accent bar
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: priorityColor,
                        boxShadow: [
                          BoxShadow(
                            color: priorityColor.withValues(alpha: 0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: Checkbox, Title, and Pin
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Checkbox
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: CustomCheckbox(
                                isChecked: task.isCompleted,
                                onChanged: onToggleComplete,
                                activeColor: AppColors.priorityLow,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Title & Description
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationThickness: 2,
                                      decorationColor: AppColors.darkTextMuted,
                                      color: task.isCompleted
                                          ? (isDark
                                              ? AppColors.darkTextMuted
                                              : AppColors.lightTextMuted)
                                          : (isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.lightTextPrimary),
                                    ),
                                  ),
                                  if (task.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      task.description,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Pin action button
                            IconButton(
                              onPressed: onTogglePin,
                              iconSize: 18,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              icon: Icon(
                                task.isPinned
                                    ? Icons.push_pin_rounded
                                    : Icons.push_pin_outlined,
                                color: task.isPinned
                                    ? const Color(0xFFFF9F1A)
                                    : AppColors.darkTextMuted
                                        .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),

                        // Subtasks mini progress bar (if any)
                        if (task.hasSubtasks) ...[
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 34),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.checklist_rounded,
                                      size: 13,
                                      color: AppColors.primaryLight,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${task.completedSubtasksCount}/${task.subtasks.length} subtasks',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: task.subtaskProgress,
                                    minHeight: 4,
                                    backgroundColor: isDark
                                        ? const Color(0xFF2A2F45)
                                        : const Color(0xFFE4E7F0),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      task.subtaskProgress == 1.0
                                          ? AppColors.priorityLow
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),

                        // Bottom tags, date, and priority
                        Padding(
                          padding: const EdgeInsets.only(left: 34),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // Priority badge
                              PriorityBadge(priority: task.priority),

                              // Category chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF131622)
                                      : const Color(0xFFF1F2F6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  task.category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ),

                              // Due Date pill (if any)
                              if (task.dueDate != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: task.isOverdue
                                        ? AppColors.priorityUrgent
                                            .withValues(alpha: 0.15)
                                        : (task.isDueToday
                                            ? AppColors.priorityHigh
                                                .withValues(alpha: 0.15)
                                            : (isDark
                                                ? const Color(0xFF131622)
                                                : const Color(0xFFF1F2F6))),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: task.isOverdue
                                          ? AppColors.priorityUrgent
                                              .withValues(alpha: 0.4)
                                          : (task.isDueToday
                                              ? AppColors.priorityHigh
                                                  .withValues(alpha: 0.4)
                                              : Colors.transparent),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 11,
                                        color: task.isOverdue
                                            ? AppColors.priorityUrgent
                                            : (task.isDueToday
                                                ? AppColors.priorityHigh
                                                : AppColors.darkTextMuted),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormatter.formatTaskDate(
                                            task.dueDate!),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: task.isOverdue
                                              ? AppColors.priorityUrgent
                                              : (task.isDueToday
                                                  ? AppColors.priorityHigh
                                                  : (isDark
                                                      ? AppColors
                                                          .darkTextSecondary
                                                      : AppColors
                                                          .lightTextSecondary)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Alarm Indicator Pill (if alarm is active)
                              if (task.hasActiveAlarm) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.35),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.alarm_on_rounded,
                                        size: 11,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        task.dueTime?.isNotEmpty == true
                                            ? task.dueTime!
                                            : 'Alarm ON',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Tags
                              for (final tag in task.tags.take(2))
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
