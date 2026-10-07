import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProductivityCard extends StatelessWidget {
  final int completedCount;
  final int pendingCount;
  final int totalCount;
  final double progress;
  final int streakDays;
  final VoidCallback? onAnalyticsTap;

  const ProductivityCard({
    super.key,
    required this.completedCount,
    required this.pendingCount,
    required this.totalCount,
    required this.progress,
    required this.streakDays,
    this.onAnalyticsTap,
  });

  String _getMotivationalQuote() {
    if (totalCount == 0) {
      return "Ready to plan your productive day?";
    } else if (progress >= 1.0) {
      return "All tasks completed! Superb focus! 🎉";
    } else if (progress >= 0.7) {
      return "Almost there! Keep that momentum going! ⚡";
    } else if (progress >= 0.4) {
      return "Great progress! Halfway through your goals! 🚀";
    } else {
      return "One step at a time. You've got this! ✨";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E2235), const Color(0xFF161926)]
              : [Colors.white, const Color(0xFFF1F2F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular Progress Ring
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      strokeWidth: 7,
                      backgroundColor: isDark
                          ? const Color(0xFF2A2F45)
                          : const Color(0xFFE4E7F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.secondary,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text(
                        '$percentage%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              // Text and Streak
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'DAILY FOCUS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: AppColors.primaryLight,
                          ),
                        ),
                        const Spacer(),
                        // Streak badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.fireGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF4757)
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_fire_department_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '$streakDays d',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getMotivationalQuote(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Bottom Stats Pills Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF131622).withValues(alpha: 0.7)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder.withValues(alpha: 0.5)
                    : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  label: 'Completed',
                  value: '$completedCount',
                  color: AppColors.priorityLow,
                  icon: Icons.check_circle_outline_rounded,
                ),
                Container(
                  height: 20,
                  width: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                _buildStatItem(
                  label: 'Pending',
                  value: '$pendingCount',
                  color: AppColors.priorityHigh,
                  icon: Icons.pending_outlined,
                ),
                Container(
                  height: 20,
                  width: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                _buildStatItem(
                  label: 'Total Today',
                  value: '$totalCount',
                  color: AppColors.primary,
                  icon: Icons.assignment_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.darkTextMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
