import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/task_alarm_service.dart';
import '../../../../core/theme/neo_brutalist_decorations.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/priority_badge.dart';
import 'project_detail_screen.dart';

class ActiveAlarmsScreen extends StatefulWidget {
  const ActiveAlarmsScreen({super.key});

  @override
  State<ActiveAlarmsScreen> createState() => _ActiveAlarmsScreenState();
}

class _ActiveAlarmsScreenState extends State<ActiveAlarmsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.dynamicBg(context),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
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
                  Text(
                    'Task Start Alarms',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  // Test alarm quick button
                  GestureDetector(
                    key: const ValueKey('test_alarm_top_btn'),
                    onTap: () {
                      TaskAlarmService.instance.triggerTestAlarm();
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: NeoBrutalist.iconButton(
                        context: context,
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  List<Task> allTasks = [];
                  if (state is TaskLoaded) {
                    allTasks = state.allTasks;
                    TaskAlarmService.instance.syncTasks(allTasks);
                  }

                  return ValueListenableBuilder<List<Task>>(
                    valueListenable:
                        TaskAlarmService.instance.upcomingAlarmsNotifier,
                    builder: (context, upcomingAlarms, _) {
                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        children: [
                          // Hero Card: Test Alarm Experience
                          _buildTestAlarmHero(context),

                          const SizedBox(height: 20),

                          // Section Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Scheduled Alarms (${upcomingAlarms.length})',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                              if (upcomingAlarms.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusCompleted
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Engine Active 🟢',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.statusCompleted,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          if (upcomingAlarms.isEmpty)
                            _buildEmptyState(context, allTasks)
                          else
                            ...upcomingAlarms.map((task) {
                              return _buildAlarmCard(context, task);
                            }),

                          const SizedBox(height: 28),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestAlarmHero(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: NeoBrutalist.card(
        context: context,
        borderRadius: 20,
        borderWidth: 2,
        shadowOffset: const Offset(0, 4),
        backgroundColor:
            isDark ? const Color(0xFF1E222D) : const Color(0xFFFFF7F5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderBlack, width: 1.5),
                ),
                child: const Icon(
                  Icons.alarm_on_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'In-App Alarm Engine',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rings automatically when your task starts',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFFA0A7B5)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Test the audio alerts, haptic feedback pulses, and the start modal now to see how it wakes you up for tasks.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: isDark
                  ? const Color(0xFFA0A7B5)
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            key: const ValueKey('hero_test_alarm_btn'),
            onTap: () {
              TaskAlarmService.instance.triggerTestAlarm();
            },
            child: Container(
              height: 44,
              decoration: NeoBrutalist.button(
                context: context,
                backgroundColor: AppColors.primary,
                borderRadius: 12,
                borderWidth: 1.5,
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Test Start Alarm Now 🔔',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmCard(BuildContext context, Task task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheduled = task.scheduledAlarmTime;
    final now = DateTime.now();

    String countdownText = '';
    if (scheduled != null) {
      final diff = scheduled.difference(now);
      if (diff.isNegative) {
        countdownText = 'Due now';
      } else if (diff.inMinutes < 60) {
        countdownText = 'In ${diff.inMinutes} mins';
      } else if (diff.inHours < 24) {
        countdownText = 'In ${diff.inHours}h ${diff.inMinutes % 60}m';
      } else {
        countdownText = DateFormat('MMM d, h:mm a').format(scheduled);
      }
    }

    final displayTime = task.dueTime?.isNotEmpty == true
        ? task.dueTime!
        : (task.timeRange?.isNotEmpty == true
            ? task.timeRange!
            : (scheduled != null
                ? DateFormat('h:mm a').format(scheduled)
                : ''));

    final offsetLabel = task.alarmOffsetMinutes == 0
        ? 'At start time'
        : '${task.alarmOffsetMinutes}m before';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: NeoBrutalist.card(
        context: context,
        borderRadius: 18,
        borderWidth: 1.5,
        shadowOffset: const Offset(0, 3.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailScreen(task: task),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Alarm Bell Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.statusInProcess.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.alarm_on_rounded,
                        size: 18,
                        color: AppColors.statusInProcess,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$displayTime ($offsetLabel)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFA0A7B5)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Countdown badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        countdownText,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Footer row with actions
                Row(
                  children: [
                    PriorityBadge(priority: task.priority),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF222632)
                            : const Color(0xFFF1F3F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFA0A7B5)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Test button for this task
                    GestureDetector(
                      onTap: () {
                        TaskAlarmService.instance.triggerTestAlarm(task);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.play_arrow_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 3),
                            Text(
                              'Test',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Turn Off Alarm
                    GestureDetector(
                      onTap: () {
                        TaskAlarmService.instance.toggleAlarm(
                          task: task,
                          enable: false,
                          onUpdateTask: (updated) {
                            context.read<TaskBloc>().add(UpdateTask(updated));
                          },
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Alarm turned off for "${task.title}"'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF222632)
                              : const Color(0xFFEDF0F3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Disable',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFA0A7B5)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, List<Task> allTasks) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF191C24) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3342) : AppColors.borderBlack,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF222632) : const Color(0xFFF6F8FA),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 30,
              color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Start Alarms',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enable an alarm when creating a task or in any project details to get notified with audio & vibration when it\'s time to begin!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary,
            ),
          ),
          if (allTasks.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Quick enable alarm on current tasks:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            ...allTasks
                .where((t) => !t.isCompleted && t.status != 'Canceled')
                .take(3)
                .map((task) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF222632)
                      : const Color(0xFFF6F8FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        TaskAlarmService.instance.toggleAlarm(
                          task: task,
                          enable: true,
                          offsetMinutes: 0,
                          onUpdateTask: (updated) {
                            context.read<TaskBloc>().add(UpdateTask(updated));
                          },
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Start Alarm activated for "${task.title}" ⏰',
                            ),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Set Alarm',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
