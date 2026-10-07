import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/neo_brutalist_decorations.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/create_task_modal.dart';
import '../widgets/neo_bottom_nav_bar.dart';
import '../widgets/recent_task_card.dart';
import '../widgets/status_summary_grid.dart';
import '../widgets/user_avatar_widget.dart';
import 'board_screen.dart';
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildDashboardTab(context),
          ScheduleScreen(onAddSubtask: _openCreateTaskModal),
          const BoardScreen(),
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

  Widget _buildDashboardTab(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          List<Task> tasks = [];
          if (state is TaskLoaded) {
            tasks = state.allTasks;
          }

          // Count stats
          final ongoingCount = tasks
              .where((t) => t.status.toLowerCase() == 'on going')
              .length;
          final inProcessCount = tasks
              .where((t) => t.status.toLowerCase() == 'in process')
              .length;
          final completedCount =
              tasks.where((t) => t.isCompleted || t.status.toLowerCase() == 'completed').length;
          final canceledCount = tasks
              .where((t) => t.status.toLowerCase() == 'canceled')
              .length;

          // Filter tasks if status card selected
          final displayedTasks = _selectedStatusFilter != null
              ? tasks.where((t) => t.status == _selectedStatusFilter).toList()
              : tasks;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Avatar + "Hi, Bruce 👋" + Grid Icon
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _currentTabIndex = 3),
                      child: const UserAvatarWidget(
                        size: 46,
                        showBorder: true,
                        backgroundColor: Color(0xFFFF9E44),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Text(
                                'Hi, Bruce',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text('👋', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Your daily adventure starts now',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        decoration: NeoBrutalist.iconButton(),
                        child: const Icon(
                          Icons.grid_view_rounded,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // 2x2 Status Summary Cards Grid
                StatusSummaryGrid(
                  ongoingCount: ongoingCount > 0 ? ongoingCount : 24,
                  inProcessCount: inProcessCount > 0 ? inProcessCount : 12,
                  completedCount: completedCount > 0 ? completedCount : 42,
                  canceledCount: canceledCount > 0 ? canceledCount : 8,
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
                    const Text(
                      'Recent Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
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
                        'No tasks in $_selectedStatusFilter',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
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
