import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/neo_brutalist_decorations.dart';
import '../../domain/entities/task.dart';
import 'circular_task_progress.dart';

class RecentTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final Color? progressColor;

  const RecentTaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.progressColor,
  });

  Color _resolveProgressColor(String title, double progress) {
    if (progressColor != null) return progressColor!;
    final lower = title.toLowerCase();
    if (lower.contains('rune')) return const Color(0xFFFA6551); // Orange/coral
    if (lower.contains('prosavvy')) return const Color(0xFF42BAAE); // Teal
    if (lower.contains('track')) return const Color(0xFFF5B335); // Yellow
    if (lower.contains('courier')) return const Color(0xFF4D86F7); // Blue
    if (progress >= 0.75) return AppColors.statusCompleted;
    if (progress >= 0.5) return AppColors.statusInProcess;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final progress = task.subtaskProgress;
    final color = _resolveProgressColor(task.title, progress);
    final taskCountLabel = task.subtasks.isNotEmpty
        ? '${task.subtasks.length} ${task.subtasks.length == 1 ? 'Task' : 'Tasks'}'
        : '1 Task';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: NeoBrutalist.card(
          context: context,
          borderRadius: 20,
          borderWidth: 1.5,
          shadowOffset: const Offset(0, 3.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dynamicText(context),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.subtitle.isNotEmpty
                        ? task.subtitle
                        : 'Digital Product Design',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.dynamicSubtext(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 15,
                        color: AppColors.dynamicText(context),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        taskCountLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dynamicText(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CircularTaskProgress(
              progress: progress,
              progressColor: color,
              size: 52,
              strokeWidth: 4.5,
            ),
          ],
        ),
      ),
    );
  }
}
