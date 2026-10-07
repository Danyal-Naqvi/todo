import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/neo_brutalist_decorations.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../widgets/circular_task_progress.dart';
import '../widgets/user_avatar_widget.dart';
import 'board_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Task task;

  const ProjectDetailScreen({super.key, required this.task});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late Task _currentTask;
  late List<SubTask> _subtasks;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _subtasks = _currentTask.subtasks.isNotEmpty
        ? List.from(_currentTask.subtasks)
        : [
            const SubTask(
              id: 'sb-1',
              title: 'Job Matching Optimization',
              isCompleted: true,
            ),
            const SubTask(
              id: 'sb-2',
              title: 'Employer Dashboard Upgrades',
              isCompleted: false,
            ),
            const SubTask(
              id: 'sb-3',
              title: 'Continuous Feedback Loop',
              isCompleted: false,
            ),
          ];
  }

  void _toggleSubtask(int index) {
    setState(() {
      final current = _subtasks[index];
      _subtasks[index] = current.copyWith(isCompleted: !current.isCompleted);
      _currentTask = _currentTask.copyWith(subtasks: _subtasks);
    });
    context.read<TaskBloc>().add(UpdateTask(_currentTask));
  }

  double get _progress {
    if (_subtasks.isEmpty) return 0.6;
    final done = _subtasks.where((s) => s.isCompleted).length;
    return done / _subtasks.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
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
                      decoration: NeoBrutalist.iconButton(),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BoardScreen(task: _currentTask),
                            ),
                          );
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: NeoBrutalist.iconButton(),
                          child: const Icon(
                            Icons.calendar_month_outlined,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: NeoBrutalist.iconButton(),
                        child: const Icon(
                          Icons.more_vert,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                _currentTask.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 20),

              // Objective Section
              const Text(
                'Objective',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _currentTask.description.isNotEmpty
                    ? _currentTask.description
                    : 'Effectively manage and coordinate the tasks involved in the development and enhancement of the Rune.io job finder website. Ensure alignment with project goals, timelines, and quality standards.\n\nCollaborate with the design team to outline the requirements for the website redesign. Clearly define the visual elements, user interface improvements, and overall user experience enhancements.',
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Info Row: Deadline, Team, Progress Ring
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Deadline badge pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE2E5E9),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_alarms_rounded,
                                size: 16,
                                color: AppColors.textPrimary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Deadline: February 6',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Team Section
                        const Text(
                          'Team',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),

                        const SizedBox(height: 6),

                        AvatarStackWidget(
                          avatarSize: 32,
                          onAddTap: () {},
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

              // Today's Tasks
              const Text(
                "Today's Tasks",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              // Subtasks List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _subtasks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final sub = _subtasks[index];
                  final assignee = index == 0
                      ? 'Jack Roberts'
                      : (index == 1 ? 'Ava Taylor' : 'Bruce Wayne');

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: NeoBrutalist.card(
                      borderRadius: 18,
                      borderWidth: 1.5,
                      shadowOffset: const Offset(0, 3.5),
                    ),
                    child: Row(
                      children: [
                        // Assignee Avatar
                        UserAvatarWidget(
                          size: 38,
                          initials: assignee.split(' ').map((n) => n[0]).join(),
                          backgroundColor: index == 0
                              ? const Color(0xFF4D86F7)
                              : (index == 1
                                  ? const Color(0xFFF5B335)
                                  : const Color(0xFFFF7A68)),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sub.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  decoration: sub.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Assignee $assignee',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Checkbox
                        GestureDetector(
                          onTap: () => _toggleSubtask(index),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: sub.isCompleted
                                  ? AppColors.statusCompleted
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.borderBlack,
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
