import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/neo_brutalist_decorations.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/create_task_modal.dart';
import '../widgets/neo_bottom_nav_bar.dart';
import '../widgets/recent_task_card.dart';
import '../widgets/status_summary_grid.dart';
import '../widgets/user_avatar_widget.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/bloc/profile_cubit.dart';
import '../../../../core/services/task_alarm_service.dart';
import 'active_alarms_screen.dart';
import 'focus_timer_screen.dart';
import 'project_detail_screen.dart';
import 'profile_screen.dart';
import 'schedule_screen.dart';
import 'task_overview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  String? _selectedStatusFilter;

  void _openCreateTaskModal() {
    CreateTaskModal.show(
      context,
      onTaskCreated: (newTask) {
        context.read<TaskBloc>().add(AddTask(newTask));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${newTask.title}" added ✨'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildDashboardTab(context),
          ScheduleScreen(
            onAddSubtask: _openCreateTaskModal,
            onBackToHome: () => setState(() => _currentTabIndex = 0),
          ),
          FocusTimerScreen(
            onBackToHome: () => setState(() => _currentTabIndex = 0),
          ),
          ProfileScreen(onBack: () => setState(() => _currentTabIndex = 0)),
        ],
      ),
      bottomNavigationBar: NeoBottomNavBar(
        currentIndex: _currentTabIndex,
        onTabSelected: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        onAddPressed: _openCreateTaskModal,
      ),
    );
  }

  String _getTaskStatusCategory(Task task) {
    if (task.isCompleted || task.status.trim().toLowerCase() == 'completed') {
      return 'Completed';
    }
    final s = task.status.trim().toLowerCase();
    if (s == 'canceled' || s == 'cancelled') {
      return 'Canceled';
    }
    if (s == 'on going' || s == 'ongoing') {
      return 'On going';
    }
    return 'In Process';
  }

  Widget _buildDashboardTab(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          List<Task> tasks = [];
          if (state is TaskLoaded) {
            tasks = state.allTasks;
          }

          // Real counts based on actual task statuses
          final ongoingCount = tasks
              .where((t) => _getTaskStatusCategory(t) == 'On going')
              .length;
          final inProcessCount = tasks
              .where((t) => _getTaskStatusCategory(t) == 'In Process')
              .length;
          final completedCount = tasks
              .where((t) => _getTaskStatusCategory(t) == 'Completed')
              .length;
          final canceledCount = tasks
              .where((t) => _getTaskStatusCategory(t) == 'Canceled')
              .length;

          // Filter tasks if status card selected
          final displayedTasks = _selectedStatusFilter != null
              ? tasks
                  .where((t) =>
                      _getTaskStatusCategory(t) == _selectedStatusFilter)
                  .toList()
              : tasks;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Avatar + "Hi, {Name} 👋" + Grid Icon
                Builder(
                  builder: (context) {
                    UserProfile userProfile = const UserProfile();
                    try {
                      userProfile = context.watch<ProfileCubit>().state;
                    } catch (_) {}

                    final firstName = userProfile.name
                        .trim()
                        .split(RegExp(r'\s+'))
                        .first;

                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _currentTabIndex = 3),
                          child: UserAvatarWidget.fromProfile(
                            userProfile,
                            size: 46,
                            showBorder: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Hi, $firstName',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('👋', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userProfile.bio.isNotEmpty
                                    ? userProfile.bio
                                    : 'Your daily adventure starts now',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Global Dark / Light Mode Toggle Button
                        Builder(
                          builder: (btnCtx) {
                            final isDarkTheme =
                                Theme.of(btnCtx).brightness == Brightness.dark;

                            return GestureDetector(
                              key: const ValueKey('home_theme_toggle_btn'),
                              onTap: () {
                                try {
                                  btnCtx.read<ThemeCubit>().toggleTheme();
                                } catch (_) {}
                              },
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: NeoBrutalist.iconButton(
                                  context: btnCtx,
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder: (child, anim) =>
                                      ScaleTransition(
                                          scale: anim, child: child),
                                  child: Icon(
                                    isDarkTheme
                                        ? Icons.light_mode_rounded
                                        : Icons.dark_mode_rounded,
                                    key: ValueKey(isDarkTheme),
                                    size: 20,
                                    color: isDarkTheme
                                        ? const Color(0xFFFFB74D)
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        // In-App Alarm Button with active badge
                        ValueListenableBuilder<List<Task>>(
                          valueListenable:
                              TaskAlarmService.instance.upcomingAlarmsNotifier,
                          builder: (context, activeAlarms, _) {
                            final hasAlarms = activeAlarms.isNotEmpty;
                            final isDarkTheme =
                                Theme.of(context).brightness == Brightness.dark;

                            return GestureDetector(
                              key: const ValueKey('home_alarm_btn'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ActiveAlarmsScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: NeoBrutalist.iconButton(
                                  context: context,
                                  backgroundColor: hasAlarms
                                      ? AppColors.primary
                                      : null,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      hasAlarms
                                          ? Icons.alarm_on_rounded
                                          : Icons.alarm_rounded,
                                      size: 20,
                                      color: hasAlarms
                                          ? Colors.white
                                          : (isDarkTheme
                                              ? AppColors.darkTextPrimary
                                              : AppColors.textPrimary),
                                    ),
                                    if (hasAlarms)
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: AppColors.statusInProcess,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.borderBlack,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        // Grid Icon Button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TaskOverviewScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: NeoBrutalist.iconButton(context: context),
                            child: Icon(
                              Icons.grid_view_rounded,
                              size: 20,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 22),

                // 2x2 Status Summary Cards Grid
                StatusSummaryGrid(
                  ongoingCount: ongoingCount,
                  inProcessCount: inProcessCount,
                  completedCount: completedCount,
                  canceledCount: canceledCount,
                  activeStatus: _selectedStatusFilter,
                  onStatusSelected: (status) {
                    setState(() {
                      if (_selectedStatusFilter == status) {
                        _selectedStatusFilter = null; // Toggle off
                      } else {
                        _selectedStatusFilter = status;
                      }
                    });
                  },
                ),

                const SizedBox(height: 28),

                // Section Title: "Recent Task"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dynamicText(context),
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (_selectedStatusFilter != null)
                      GestureDetector(
                        onTap: () => setState(() => _selectedStatusFilter = null),
                        child: Text(
                          'Clear filter ($_selectedStatusFilter)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Recent Tasks Cards List
                if (displayedTasks.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Text(
                        _selectedStatusFilter != null
                            ? 'No $_selectedStatusFilter tasks'
                            : 'No tasks found',
                        style: TextStyle(
                          color: AppColors.dynamicSubtext(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayedTasks.length,
                    itemBuilder: (context, index) {
                      final task = displayedTasks[index];
                      return RecentTaskCard(
                        task: task,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailScreen(task: task),
                            ),
                          );
                        },
                      );
                    },
                  ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
