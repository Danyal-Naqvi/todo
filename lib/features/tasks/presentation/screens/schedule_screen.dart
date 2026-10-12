import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/neo_brutalist_decorations.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/create_task_modal.dart';
import 'project_detail_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final VoidCallback? onAddSubtask;
  final VoidCallback? onBackToHome;

  const ScheduleScreen({
    super.key,
    this.onAddSubtask,
    this.onBackToHome,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selectedDate;
  late DateTime _weekStart;
  String _selectedStatusFilter = 'All'; // 'All', 'In Process', 'On going', 'Completed'

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _weekStart = _computeWeekStart(_selectedDate);
  }

  DateTime _computeWeekStart(DateTime date) {
    // Week starting Monday
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }

  void _shiftWeek(int weeks) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: weeks * 7));
      _selectedDate = _weekStart;
    });
  }

  void _jumpToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
      _weekStart = _computeWeekStart(_selectedDate);
    });
  }

  Future<void> _pickDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primary,
                    surface: Color(0xFF191C24),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    onSurface: AppColors.textPrimary,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
        _weekStart = _computeWeekStart(_selectedDate);
      });
    }
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int? _parseHourString(String text) {
    final clean = text.toLowerCase().replaceAll('.', ':');
    final regex = RegExp(r'(\d{1,2})(?::\d{2})?\s*(am|pm)?');
    final match = regex.firstMatch(clean);
    if (match != null) {
      var hour = int.tryParse(match.group(1) ?? '');
      final period = match.group(2);
      if (hour != null) {
        if (period == 'pm' && hour < 12) hour += 12;
        if (period == 'am' && hour == 12) hour = 0;
        return hour;
      }
    }
    return null;
  }

  int? _getTaskHour(Task task) {
    if (task.dueTime != null && task.dueTime!.trim().isNotEmpty) {
      final h = _parseHourString(task.dueTime!);
      if (h != null) return h;
    }
    if (task.timeRange != null && task.timeRange!.trim().isNotEmpty) {
      final start = task.timeRange!.split('-').first.trim();
      final h = _parseHourString(start);
      if (h != null) return h;
    }
    if (task.dueDate != null &&
        (task.dueDate!.hour != 0 || task.dueDate!.minute != 0)) {
      return task.dueDate!.hour;
    }
    return null;
  }

  void _openAddTask([String? hourLabel]) {
    CreateTaskModal.show(
      context,
      initialDate: _selectedDate,
      initialTime: hourLabel,
      onTaskCreated: (newTask) {
        context.read<TaskBloc>().add(AddTask(newTask));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scheduled "${newTask.title}" ✨'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _toggleTaskComplete(Task task) {
    final isNowComp = !task.isCompleted;
    final newStatus = isNowComp ? 'Completed' : 'In Process';
    final updated = task.copyWith(
      isCompleted: isNowComp,
      status: newStatus,
      completedAt: isNowComp ? DateTime.now() : null,
    );
    context.read<TaskBloc>().add(UpdateTask(updated));
  }

  void _updateTaskStatus(Task task, String newStatus) {
    final isComp = newStatus.trim().toLowerCase() == 'completed';
    final updated = task.copyWith(
      status: newStatus,
      isCompleted: isComp,
      completedAt: isComp ? DateTime.now() : null,
    );
    context.read<TaskBloc>().add(UpdateTask(updated));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = _isSameDay(_selectedDate, now);

    return Scaffold(
      backgroundColor: AppColors.dynamicBg(context),
      body: SafeArea(
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            List<Task> allTasks = [];
            if (state is TaskLoaded) {
              allTasks = state.allTasks;
            }

            // Tasks due on selected date
            final tasksForSelectedDay = allTasks.where((t) {
              final matchesDate = _isSameDay(t.dueDate, _selectedDate);
              if (!matchesDate) return false;
              if (_selectedStatusFilter == 'All') return true;
              return t.status.trim().toLowerCase() ==
                  _selectedStatusFilter.toLowerCase();
            }).toList();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  _buildTopBar(),

                  const SizedBox(height: 18),

                  // Date Title Row with Quick Controls
                  _buildDateHeader(isToday, tasksForSelectedDay.length),

                  const SizedBox(height: 16),

                  // Horizontal Date Strip (Dynamic Week)
                  _buildWeekStrip(allTasks),

                  const SizedBox(height: 20),

                  // Filter Chips Row
                  _buildFilterChips(),

                  const SizedBox(height: 24),

                  // Timeline / Schedule View
                  _buildTimelineSection(tasksForSelectedDay),

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            if (widget.onBackToHome != null) {
              widget.onBackToHome!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
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
        Row(
          children: [
            GestureDetector(
              onTap: _jumpToToday,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: NeoBrutalist.card(
                  context: context,
                  borderRadius: 14,
                  borderWidth: 1.5,
                  shadowOffset: const Offset(0, 2),
                ),
                child: Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
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
              onSelected: (val) {
                switch (val) {
                  case 'today':
                    _jumpToToday();
                    break;
                  case 'calendar':
                    _pickDate();
                    break;
                  case 'add_task':
                    _openAddTask();
                    break;
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'today',
                  child: Row(
                    children: [
                      Icon(Icons.today_rounded,
                          size: 18,
                          color: isDark ? Colors.white : AppColors.textPrimary),
                      const SizedBox(width: 10),
                      Text('Jump to Today',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textPrimary)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'calendar',
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_rounded,
                          size: 18,
                          color: isDark ? Colors.white : AppColors.textPrimary),
                      const SizedBox(width: 10),
                      Text('Pick Date',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textPrimary)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'add_task',
                  child: Row(
                    children: const [
                      Icon(Icons.add_task_rounded,
                          size: 18, color: AppColors.primary),
                      SizedBox(width: 10),
                      Text('Add Task for this Day',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
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
      ],
    );
  }

  Widget _buildDateHeader(bool isToday, int taskCount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _pickDate,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  isToday
                      ? 'Today • $taskCount scheduled ${taskCount == 1 ? 'task' : 'tasks'}'
                      : '$taskCount scheduled ${taskCount == 1 ? 'task' : 'tasks'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.chevron_left_rounded,
                    size: 28,
                    color: isDark ? Colors.white : AppColors.textPrimary),
                onPressed: () => _shiftWeek(-1),
                tooltip: 'Previous week',
              ),
              const SizedBox(width: 4),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.chevron_right_rounded,
                    size: 28,
                    color: isDark ? Colors.white : AppColors.textPrimary),
                onPressed: () => _shiftWeek(1),
                tooltip: 'Next week',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStrip(List<Task> allTasks) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weekDays = List.generate(7, (i) => _weekStart.add(Duration(days: i)));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: weekDays.map((day) {
          final isSelected = _isSameDay(day, _selectedDate);
          final isTodayDay = _isSameDay(day, DateTime.now());
          final countForDay =
              allTasks.where((t) => _isSameDay(t.dueDate, day)).length;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = day);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? const Color(0xFF191C24) : Colors.white),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? Colors.white : AppColors.borderBlack)
                      : (isTodayDay
                          ? AppColors.primary
                          : (isDark
                              ? const Color(0xFF2E3342)
                              : const Color(0xFFE2E5E8))),
                  width: isSelected || isTodayDay ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.6)
                              : AppColors.borderBlack,
                          offset: const Offset(0, 3),
                          blurRadius: 0,
                        )
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('E').format(day),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isTodayDay
                              ? AppColors.primary
                              : (isDark
                                  ? const Color(0xFFA0A7B5)
                                  : AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Small indicator dot for task count
                  if (countForDay > 0)
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 5),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterChips() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filters = ['All', 'In Process', 'On going', 'Completed'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedStatusFilter == f;
          return GestureDetector(
            onTap: () => setState(() => _selectedStatusFilter = f),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.textPrimary)
                    : (isDark ? const Color(0xFF191C24) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? (isSelected ? Colors.white : const Color(0xFF2E3342))
                      : AppColors.borderBlack,
                  width: 1.5,
                ),
              ),
              child: Text(
                f,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? (isDark ? const Color(0xFF14171A) : Colors.white)
                      : (isDark
                          ? const Color(0xFFA0A7B5)
                          : AppColors.textPrimary),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineSection(List<Task> tasksForSelectedDay) {
    // Map tasks to their hours
    final Map<int, List<Task>> tasksByHour = {};
    final List<Task> allDayTasks = [];

    for (final task in tasksForSelectedDay) {
      final hour = _getTaskHour(task);
      if (hour != null) {
        tasksByHour.putIfAbsent(hour, () => []).add(task);
      } else {
        allDayTasks.add(task);
      }
    }

    // Standard daytime hours 08 am - 07 pm plus any hour with scheduled tasks
    final Set<int> allHours = {8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19};
    allHours.addAll(tasksByHour.keys);
    final sortedHours = allHours.toList()..sort();

    final slots = sortedHours.map((h) {
      final period = h >= 12 ? 'pm' : 'am';
      final displayHour = h % 12 == 0 ? 12 : h % 12;
      final label = '${displayHour.toString().padLeft(2, '0')} $period';
      return {'hour': h, 'label': label};
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // All Day / Anytime Tasks (if any)
        if (allDayTasks.isNotEmpty) ...[
          _buildAllDaySection(allDayTasks),
          const SizedBox(height: 20),
        ],

        // Hourly Timeline Slots
        ...slots.map((slot) {
          final hour = slot['hour'] as int;
          final label = slot['label'] as String;
          final tasksAtHour = tasksByHour[hour] ?? [];

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildTimelineRow(
              timeLabel: label,
              tasks: tasksAtHour,
              onAddTap: () => _openAddTask(label),
            ),
          );
        }),

        const SizedBox(height: 12),

        // Add new subtask / task button pill
        _buildAddSubtaskButton(),
      ],
    );
  }

  Widget _buildAllDaySection(List<Task> allDayTasks) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: NeoBrutalist.card(
        context: context,
        borderRadius: 18,
        borderWidth: 1.5,
        shadowOffset: const Offset(0, 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded,
                  size: 16,
                  color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Flexible / All-Day Tasks',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...allDayTasks.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildTaskCard(t),
              )),
        ],
      ),
    );
  }

  Widget _buildTimelineRow({
    required String timeLabel,
    required List<Task> tasks,
    required VoidCallback onAddTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 54,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              timeLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary,
              ),
            ),
          ),
        ),
        Expanded(
          child: tasks.isNotEmpty
              ? Column(
                  children: tasks.map((t) => _buildTaskCard(t)).toList(),
                )
              : _buildEmptySlot(timeLabel, onAddTap),
        ),
      ],
    );
  }

  Widget _buildEmptySlot(String timeLabel, VoidCallback onAddTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onAddTap,
      child: Container(
        height: 48,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF191C24).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF2E3342) : const Color(0xFFE6E9EC),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'No task • Tap to schedule at $timeLabel',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF6E7482) : AppColors.textMuted,
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF222632) : const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add,
                size: 14,
                color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasSubtasks = task.subtasks.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailScreen(task: task),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: NeoBrutalist.card(
          context: context,
          borderRadius: 18,
          borderWidth: 1.5,
          shadowOffset: const Offset(0, 3.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title & 3-dots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick completion toggle
                      GestureDetector(
                        onTap: () => _toggleTaskComplete(task),
                        child: Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 2, right: 10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: task.isCompleted
                                ? AppColors.statusCompleted
                                : (isDark ? const Color(0xFF222632) : Colors.white),
                            border: Border.all(
                              color: task.isCompleted
                                  ? AppColors.statusCompleted
                                  : (isDark ? const Color(0xFF383E4C) : AppColors.borderBlack),
                              width: 1.5,
                            ),
                          ),
                          child: task.isCompleted
                              ? const Icon(Icons.check,
                                  size: 13, color: Colors.white)
                              : null,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  offset: const Offset(0, 36),
                  color: isDark ? const Color(0xFF191C24) : Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                        color: isDark ? const Color(0xFF2E3342) : AppColors.borderBlack,
                        width: 1.5),
                  ),
                  onSelected: (val) {
                    switch (val) {
                      case 'details':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProjectDetailScreen(task: task),
                          ),
                        );
                        break;
                      case 'toggle':
                        _toggleTaskComplete(task);
                        break;
                      case 'ongoing':
                        _updateTaskStatus(task, 'On going');
                        break;
                      case 'in_process':
                        _updateTaskStatus(task, 'In Process');
                        break;
                      case 'cancel':
                        _updateTaskStatus(task, 'Canceled');
                        break;
                      case 'delete':
                        context.read<TaskBloc>().add(DeleteTask(task.id));
                        break;
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'details',
                      child: Text('View Details',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textPrimary)),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(
                        task.isCompleted
                            ? 'Mark Incomplete'
                            : 'Mark as Completed',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textPrimary),
                      ),
                    ),
                    if (task.status != 'On going')
                      PopupMenuItem(
                        value: 'ongoing',
                        child: Text('Mark as On going',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.textPrimary)),
                      ),
                    if (task.status != 'In Process')
                      PopupMenuItem(
                        value: 'in_process',
                        child: Text('Mark as In Process',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.textPrimary)),
                      ),
                    if (!task.isCompleted && task.status != 'Canceled')
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Text('Cancel Task',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.statusCanceled)),
                      ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Task',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.statusCanceled)),
                    ),
                  ],
                  child: Icon(
                    Icons.more_horiz,
                    size: 20,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Time range & Alarm indicator
            Row(
              children: [
                Text(
                  task.timeRange ??
                      (task.dueTime != null
                          ? '${task.dueTime}'
                          : 'Scheduled for today'),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF7E8696) : AppColors.textMuted,
                  ),
                ),
                if (task.hasActiveAlarm) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.alarm_on_rounded,
                    size: 13,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),

            // Category or Subtitle Pill
            if (task.category.isNotEmpty || task.subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF222632) : const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.category.isNotEmpty ? task.category : task.subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFA0A7B5) : AppColors.textPrimary,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Bottom Row: Subtasks progress (left) + Prominent Status Indicator (right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (hasSubtasks)
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 14,
                        color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${task.completedSubtasksCount}/${task.subtasks.length} Subtasks',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox.shrink(),

                // Prominent status indicator replacing circled avatars & arrow
                _buildProminentStatusBadge(task.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddSubtaskButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _openAddTask(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: NeoBrutalist.card(
          context: context,
          borderRadius: 22,
          borderWidth: 1.5,
          shadowOffset: const Offset(0, 3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Add new task for this day',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDark ? AppColors.primary : Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProminentStatusBadge(String status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lower = status.trim().toLowerCase();
    Color bg;
    Color border;
    Color textCol;
    IconData icon;
    String label;

    if (lower == 'completed') {
      bg = isDark ? const Color(0xFF10332B) : const Color(0xFFE6F7F5);
      border = AppColors.statusCompleted;
      textCol = isDark ? const Color(0xFF42BAAE) : const Color(0xFF0D9488);
      icon = Icons.check_circle_rounded;
      label = 'Completed';
    } else if (lower == 'on going' || lower == 'ongoing') {
      bg = isDark ? const Color(0xFF332014) : const Color(0xFFFFF7ED);
      border = AppColors.statusOnGoing;
      textCol = isDark ? const Color(0xFFFFA26B) : const Color(0xFFC2410C);
      icon = Icons.bolt_rounded;
      label = 'On going';
    } else if (lower == 'canceled' || lower == 'cancelled') {
      bg = isDark ? const Color(0xFF331414) : const Color(0xFFFEF2F2);
      border = AppColors.statusCanceled;
      textCol = isDark ? const Color(0xFFFF7A7A) : const Color(0xFFDC2626);
      icon = Icons.cancel_rounded;
      label = 'Canceled';
    } else {
      bg = isDark ? const Color(0xFF14243B) : const Color(0xFFEFF6FF);
      border = AppColors.statusInProcess;
      textCol = isDark ? const Color(0xFF70A9FF) : const Color(0xFF2563EB);
      icon = Icons.timelapse_rounded;
      label = 'In Process';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: border.withValues(alpha: 0.18),
            offset: const Offset(0, 1.5),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textCol),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: textCol,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
