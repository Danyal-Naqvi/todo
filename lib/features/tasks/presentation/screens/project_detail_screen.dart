import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/neo_brutalist_decorations.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../widgets/circular_task_progress.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Task task;

  const ProjectDetailScreen({super.key, required this.task});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late Task _currentTask;
  late List<SubTask> _subtasks;
  final TextEditingController _newSubtaskController = TextEditingController();
  bool _isAddingSubtask = false;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _subtasks = List.from(_currentTask.subtasks);
  }

  @override
  void dispose() {
    _newSubtaskController.dispose();
    super.dispose();
  }

  void _toggleSubtask(int index) {
    setState(() {
      final current = _subtasks[index];
      _subtasks[index] = current.copyWith(isCompleted: !current.isCompleted);
      final allDone =
          _subtasks.isNotEmpty && _subtasks.every((s) => s.isCompleted);
      _currentTask = _currentTask.copyWith(
        subtasks: _subtasks,
        isCompleted: allDone,
        status: allDone
            ? 'Completed'
            : (_currentTask.status == 'Completed'
                ? 'In Process'
                : _currentTask.status),
      );
    });
    context.read<TaskBloc>().add(UpdateTask(_currentTask));
  }

  void _addSubtask(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _subtasks.add(
        SubTask(
          id: const Uuid().v4(),
          title: trimmed,
          isCompleted: false,
        ),
      );
      final allDone =
          _subtasks.isNotEmpty && _subtasks.every((s) => s.isCompleted);
      _currentTask = _currentTask.copyWith(
        subtasks: _subtasks,
        isCompleted: allDone,
        status: allDone
            ? 'Completed'
            : (_currentTask.status == 'Completed'
                ? 'In Process'
                : _currentTask.status),
      );
      _newSubtaskController.clear();
      _isAddingSubtask = false;
    });
    context.read<TaskBloc>().add(UpdateTask(_currentTask));
  }

  void _deleteSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
      final allDone =
          _subtasks.isNotEmpty && _subtasks.every((s) => s.isCompleted);
      _currentTask = _currentTask.copyWith(
        subtasks: _subtasks,
        isCompleted: allDone,
        status: allDone
            ? 'Completed'
            : (_currentTask.status == 'Completed'
                ? 'In Process'
                : _currentTask.status),
      );
    });
    context.read<TaskBloc>().add(UpdateTask(_currentTask));
  }

  double get _progress {
    if (_subtasks.isEmpty) {
      return _currentTask.isCompleted ? 1.0 : (_currentTask.customProgress ?? 0.0);
    }
    final done = _subtasks.where((s) => s.isCompleted).length;
    return done / _subtasks.length;
  }

  bool get _isCompleted =>
      _currentTask.isCompleted ||
      _currentTask.status.trim().toLowerCase() == 'completed';

  bool get _isCanceled {
    final s = _currentTask.status.trim().toLowerCase();
    return s == 'canceled' || s == 'cancelled';
  }

  Color _statusColor(String status) {
    final lower = status.trim().toLowerCase();
    if (lower == 'on going' || lower == 'ongoing') {
      return AppColors.statusOnGoing;
    }
    if (lower == 'completed') {
      return AppColors.statusCompleted;
    }
    if (lower == 'canceled' || lower == 'cancelled') {
      return AppColors.statusCanceled;
    }
    return AppColors.statusInProcess;
  }

  void _updateStatus(String newStatus) {
    final isComp = newStatus.trim().toLowerCase() == 'completed';
    setState(() {
      _currentTask = _currentTask.copyWith(
        status: newStatus,
        isCompleted: isComp,
        completedAt: isComp ? DateTime.now() : null,
      );
    });
    context.read<TaskBloc>().add(UpdateTask(_currentTask));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus == 'Canceled'
              ? 'Task cancelled and moved to Canceled category ✕'
              : 'Task status changed to $newStatus ✨',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _statusColor(newStatus),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmDelete() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF191C24) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: isDark ? const Color(0xFF2E3342) : AppColors.borderBlack,
              width: 2),
        ),
        title: Text(
          'Delete Task',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to permanently delete this task?',
          style: TextStyle(
              color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusCanceled,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<TaskBloc>().add(DeleteTask(_currentTask.id));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final timeSuffix = _currentTask.dueTime != null && _currentTask.dueTime!.isNotEmpty
        ? ' • ${_currentTask.dueTime}'
        : '';
    final deadlineFormatted = _currentTask.dueDate != null
        ? 'Deadline: ${DateFormat('MMMM d').format(_currentTask.dueDate!)}$timeSuffix'
        : 'No deadline';

    return Scaffold(
      backgroundColor: AppColors.dynamicBg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: NeoBrutalist.iconButton(context: context),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    offset: const Offset(0, 48),
                    color: isDark ? const Color(0xFF191C24) : Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF2E3342) : AppColors.borderBlack,
                        width: 2,
                      ),
                    ),
                    onSelected: (action) {
                      switch (action) {
                        case 'cancel':
                          _updateStatus('Canceled');
                          break;
                        case 'restore':
                          _updateStatus('In Process');
                          break;
                        case 'ongoing':
                          _updateStatus('On going');
                          break;
                        case 'in_process':
                          _updateStatus('In Process');
                          break;
                        case 'completed':
                          _updateStatus('Completed');
                          break;
                        case 'delete':
                          _confirmDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (!_isCompleted && !_isCanceled) ...[
                        PopupMenuItem(
                          value: 'cancel',
                          child: Row(
                            children: const [
                              Icon(
                                Icons.cancel_outlined,
                                size: 18,
                                color: AppColors.statusCanceled,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Cancel Task',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.statusCanceled,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                      ] else if (_isCanceled) ...[
                        PopupMenuItem(
                          value: 'restore',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.restore_rounded,
                                size: 18,
                                color: AppColors.statusInProcess,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Restore to In Process',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                      ],

                      if (_currentTask.status != 'On going')
                        PopupMenuItem(
                          value: 'ongoing',
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.statusOnGoing,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Mark as On going',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (_currentTask.status != 'In Process')
                        PopupMenuItem(
                          value: 'in_process',
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.statusInProcess,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Mark as In Process',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (!_isCompleted)
                        PopupMenuItem(
                          value: 'completed',
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.statusCompleted,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Mark as Completed',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const PopupMenuDivider(),

                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Delete Task',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: NeoBrutalist.iconButton(context: context),
                      child: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Title & Status Badge Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _currentTask.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(_currentTask.status)
                          .withValues(alpha: isDark ? 0.25 : 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _statusColor(_currentTask.status),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _statusColor(_currentTask.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _currentTask.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _statusColor(_currentTask.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Objective Section
              Text(
                'Objective',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _currentTask.description.trim().isNotEmpty
                    ? _currentTask.description.trim()
                    : 'No objective provided for this task.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: _currentTask.description.trim().isNotEmpty
                      ? (isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary)
                      : (isDark ? const Color(0xFF6E7482) : AppColors.textMuted),
                  fontStyle: _currentTask.description.trim().isNotEmpty
                      ? FontStyle.normal
                      : FontStyle.italic,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Info Row: Real Deadline + Progress Ring
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Deadline badge pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF222632) : const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2E3342) : const Color(0xFFE2E5E9),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_alarms_rounded,
                          size: 16,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          deadlineFormatted,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Circular Progress Indicator
                  CircularTaskProgress(
                    progress: _progress,
                    progressColor: AppColors.primary,
                    size: 72,
                    strokeWidth: 6,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Subtasks Section Header with Add button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _subtasks.isEmpty
                        ? 'Subtasks'
                        : 'Subtasks (${_subtasks.where((s) => s.isCompleted).length}/${_subtasks.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAddingSubtask = !_isAddingSubtask;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: NeoBrutalist.button(
                        context: context,
                        backgroundColor: _isAddingSubtask
                            ? const Color(0xFF6C757D)
                            : AppColors.primary,
                        borderRadius: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isAddingSubtask ? Icons.close : Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isAddingSubtask ? 'Cancel' : 'Add Subtask',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Inline Add Subtask Input Field (shown when tapped)
              if (_isAddingSubtask) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: NeoBrutalist.card(
                    context: context,
                    borderRadius: 16,
                    borderWidth: 1.5,
                    shadowOffset: const Offset(0, 2.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newSubtaskController,
                          autofocus: true,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter subtask title...',
                            hintStyle: TextStyle(
                              color: isDark ? const Color(0xFF6E7482) : AppColors.textMuted,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          onSubmitted: (val) => _addSubtask(val),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _addSubtask(_newSubtaskController.text),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: NeoBrutalist.button(
                            context: context,
                            backgroundColor: AppColors.primary,
                            borderRadius: 12,
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Real Subtasks List or Empty State
              if (_subtasks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 28, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF191C24) : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2E3342) : const Color(0xFFE2E5E9),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.checklist_rounded,
                          size: 26,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No subtasks yet',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap "Add Subtask" above to create action items',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _subtasks.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final sub = _subtasks[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: NeoBrutalist.card(
                        context: context,
                        borderRadius: 18,
                        borderWidth: 1.5,
                        shadowOffset: const Offset(0, 3.5),
                      ),
                      child: Row(
                        children: [
                          // Status Checkbox
                          GestureDetector(
                            onTap: () => _toggleSubtask(index),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: sub.isCompleted
                                    ? AppColors.statusCompleted
                                    : (isDark ? const Color(0xFF222632) : Colors.white),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: sub.isCompleted
                                      ? AppColors.statusCompleted
                                      : (isDark ? const Color(0xFF383E4C) : AppColors.borderBlack),
                                  width: 1.5,
                                ),
                              ),
                              child: sub.isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      size: 18,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),

                          const SizedBox(width: 14),

                          // Subtask Title
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: sub.isCompleted
                                        ? (isDark ? const Color(0xFF6E7482) : AppColors.textMuted)
                                        : (isDark ? Colors.white : AppColors.textPrimary),
                                    decoration: sub.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  sub.isCompleted ? 'Completed' : 'Pending',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: sub.isCompleted
                                        ? AppColors.statusCompleted
                                        : AppColors.statusInProcess,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Delete subtask button
                          GestureDetector(
                            onTap: () => _deleteSubtask(index),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: isDark
                                    ? const Color(0xFF6E7482)
                                    : AppColors.textMuted.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
