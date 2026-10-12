import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/task_alarm_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_priority.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../widgets/custom_checkbox.dart';
import '../widgets/priority_badge.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  final _newSubtaskController = TextEditingController();

  late TaskPriority _priority;
  late String _category;
  late DateTime? _dueDate;
  late bool _isCompleted;
  late bool _isPinned;
  late bool _isAlarmEnabled;
  late int _alarmOffsetMinutes;
  late List<SubTask> _subtasks;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _priority = widget.task.priority;
    _category = widget.task.category;
    _dueDate = widget.task.dueDate;
    _isCompleted = widget.task.isCompleted;
    _isPinned = widget.task.isPinned;
    _isAlarmEnabled = widget.task.isAlarmEnabled;
    _alarmOffsetMinutes = widget.task.alarmOffsetMinutes;
    _subtasks = List.from(widget.task.subtasks);

    _titleController.addListener(_markChanged);
    _descController.addListener(_markChanged);
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _newSubtaskController.dispose();
    super.dispose();
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final updated = widget.task.copyWith(
      title: title,
      description: _descController.text.trim(),
      priority: _priority,
      category: _category,
      dueDate: _dueDate,
      isCompleted: _isCompleted,
      isPinned: _isPinned,
      isAlarmEnabled: _isAlarmEnabled,
      hasReminder: _isAlarmEnabled,
      alarmOffsetMinutes: _alarmOffsetMinutes,
      subtasks: _subtasks,
      status: _isCompleted
          ? 'Completed'
          : (widget.task.status == 'Completed'
              ? 'In Process'
              : widget.task.status),
      completedAt: _isCompleted && widget.task.completedAt == null
          ? DateTime.now()
          : (!_isCompleted ? null : widget.task.completedAt),
    );

    context.read<TaskBloc>().add(UpdateTask(updated));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task updated successfully ✨'),
        duration: Duration(seconds: 1),
      ),
    );
    Navigator.pop(context);
  }

  void _addSubtask() {
    final text = _newSubtaskController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _subtasks.add(SubTask(
          id: const Uuid().v4(),
          title: text,
          isCompleted: false,
        ));
        _newSubtaskController.clear();
        _hasChanges = true;
      });
    }
  }

  void _toggleSubtask(int index) {
    setState(() {
      _subtasks[index] = _subtasks[index].copyWith(
        isCompleted: !_subtasks[index].isCompleted,
      );
      _hasChanges = true;
    });
  }

  void _deleteSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Details',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: _isPinned ? const Color(0xFFFF9F1A) : null,
            ),
            onPressed: () {
              setState(() {
                _isPinned = !_isPinned;
                _hasChanges = true;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.priorityUrgent),
            onPressed: () async {
              final taskBloc = context.read<TaskBloc>();
              final navigator = Navigator.of(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor:
                      isDark ? AppColors.darkCard : Colors.white,
                  title: const Text('Delete Task?'),
                  content: const Text(
                    'This action cannot be undone.',
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
              );

              if (confirm == true) {
                taskBloc.add(DeleteTask(widget.task.id));
                navigator.pop();
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: ElevatedButton(
            onPressed: _saveTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner with Quick Completion Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isCompleted
                    ? AppColors.priorityLow.withValues(alpha: 0.15)
                    : (isDark ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _isCompleted
                      ? AppColors.priorityLow.withValues(alpha: 0.4)
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              child: Row(
                children: [
                  CustomCheckbox(
                    isChecked: _isCompleted,
                    size: 26,
                    activeColor: AppColors.priorityLow,
                    onChanged: (val) {
                      setState(() {
                        _isCompleted = val;
                        _hasChanges = true;
                      });
                    },
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isCompleted ? 'Completed' : 'Mark as Complete',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _isCompleted
                                ? AppColors.priorityLow
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                          ),
                        ),
                        Text(
                          _isCompleted
                              ? 'Great work conquering this task!'
                              : 'Tap to mark this task finished',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Title
            const Text(
              'TASK TITLE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.darkTextMuted,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Task Title',
                fillColor:
                    isDark ? AppColors.darkCard : AppColors.lightCard,
              ),
            ),

            const SizedBox(height: 18),

            // Description / Notes
            const Text(
              'DESCRIPTION & NOTES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.darkTextMuted,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              maxLines: 4,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add context, checklists, or steps...',
                fillColor:
                    isDark ? AppColors.darkCard : AppColors.lightCard,
              ),
            ),

            const SizedBox(height: 20),

            // Priority and Category Selectors Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PRIORITY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.darkTextMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<TaskPriority>(
                            value: _priority,
                            isExpanded: true,
                            dropdownColor: isDark
                                ? AppColors.darkSurface
                                : Colors.white,
                            items: TaskPriority.values.map((p) {
                              return DropdownMenuItem(
                                value: p,
                                child: PriorityBadge(priority: p),
                              );
                            }).toList(),
                            onChanged: (p) {
                              if (p != null) {
                                setState(() {
                                  _priority = p;
                                  _hasChanges = true;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CATEGORY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.darkTextMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _category,
                            isExpanded: true,
                            dropdownColor: isDark
                                ? AppColors.darkSurface
                                : Colors.white,
                            items: AppConstants.defaultCategories.map((c) {
                              final name = c['name'] as String;
                              return DropdownMenuItem(
                                value: name,
                                child: Row(
                                  children: [
                                    Icon(c['icon'] as IconData,
                                        size: 16, color: c['color'] as Color),
                                    const SizedBox(width: 8),
                                    Text(name,
                                        style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (cat) {
                              if (cat != null) {
                                setState(() {
                                  _category = cat;
                                  _hasChanges = true;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Due Date Row
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DUE DATE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.darkTextMuted,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setState(() {
                        _dueDate = picked;
                        _hasChanges = true;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color:
                          isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _dueDate == null
                              ? 'No due date set'
                              : DateFormatter.formatFullDate(_dueDate!),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _dueDate == null
                                ? AppColors.darkTextMuted
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                          ),
                        ),
                        const Spacer(),
                        if (_dueDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              setState(() {
                                _dueDate = null;
                                _hasChanges = true;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // In-App Start Alarm
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TASK START ALARM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.darkTextMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isAlarmEnabled
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                      width: _isAlarmEnabled ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isAlarmEnabled
                            ? Icons.alarm_on_rounded
                            : Icons.alarm_off_rounded,
                        color: _isAlarmEnabled
                            ? AppColors.primary
                            : AppColors.darkTextMuted,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isAlarmEnabled ? 'Alarm Active 🔔' : 'Alarm Disabled',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              _isAlarmEnabled
                                  ? 'Will ring when scheduled start time arrives'
                                  : 'Turn on to receive start alert',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isAlarmEnabled) ...[
                        GestureDetector(
                          onTap: () {
                            TaskAlarmService.instance
                                .triggerTestAlarm(widget.task);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Test',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isAlarmEnabled = !_isAlarmEnabled;
                            _hasChanges = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isAlarmEnabled
                                ? AppColors.primary
                                : (isDark
                                    ? const Color(0xFF2B303E)
                                    : const Color(0xFFE8ECEF)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _isAlarmEnabled ? 'ON' : 'OFF',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _isAlarmEnabled
                                  ? Colors.white
                                  : (isDark
                                      ? const Color(0xFFA0A7B5)
                                      : AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Subtasks checklist section
            Row(
              children: [
                const Text(
                  'SUBTASKS / CHECKLIST',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.darkTextMuted,
                  ),
                ),
                const Spacer(),
                if (_subtasks.isNotEmpty)
                  Text(
                    '${_subtasks.where((s) => s.isCompleted).length}/${_subtasks.length} done',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLight,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress bar
            if (_subtasks.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _subtasks.where((s) => s.isCompleted).length /
                      _subtasks.length,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? const Color(0xFF2A2F45)
                      : const Color(0xFFE4E7F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Subtask items
            for (int i = 0; i < _subtasks.length; i++)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    CustomCheckbox(
                      isChecked: _subtasks[i].isCompleted,
                      size: 20,
                      activeColor: AppColors.secondary,
                      onChanged: (_) => _toggleSubtask(i),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _subtasks[i].title,
                        style: TextStyle(
                          fontSize: 14,
                          decoration: _subtasks[i].isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: _subtasks[i].isCompleted
                              ? AppColors.darkTextMuted
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _deleteSubtask(i),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Add subtask input field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newSubtaskController,
                    style: const TextStyle(fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Add a subtask...',
                      fillColor: isDark
                          ? AppColors.darkCard
                          : AppColors.lightCard,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    onSubmitted: (_) => _addSubtask(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addSubtask,
                  icon: const Icon(Icons.add_rounded, size: 22),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
