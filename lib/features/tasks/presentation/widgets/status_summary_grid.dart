import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StatusSummaryGrid extends StatelessWidget {
  final int ongoingCount;
  final int inProcessCount;
  final int completedCount;
  final int canceledCount;
  final Function(String status)? onStatusSelected;
  final String? activeStatus;

  const StatusSummaryGrid({
    super.key,
    this.ongoingCount = 24,
    this.inProcessCount = 12,
    this.completedCount = 42,
    this.canceledCount = 8,
    this.onStatusSelected,
    this.activeStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatusCard(
                title: 'On going',
                count: ongoingCount,
                color: AppColors.statusOnGoing,
                icon: Icons.sync_rounded,
                isSelected: activeStatus == 'On going',
                onTap: () => onStatusSelected?.call('On going'),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatusCard(
                title: 'In Process',
                count: inProcessCount,
                color: AppColors.statusInProcess,
                icon: Icons.access_time_filled_rounded,
                isSelected: activeStatus == 'In Process',
                onTap: () => onStatusSelected?.call('In Process'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _StatusCard(
                title: 'Completed',
                count: completedCount,
                color: AppColors.statusCompleted,
                icon: Icons.assignment_turned_in_rounded,
                isSelected: activeStatus == 'Completed',
                onTap: () => onStatusSelected?.call('Completed'),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatusCard(
                title: 'Canceled',
                count: canceledCount,
                color: AppColors.statusCanceled,
                icon: Icons.assignment_late_rounded,
                isSelected: activeStatus == 'Canceled',
                onTap: () => onStatusSelected?.call('Canceled'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: AppColors.borderBlack, width: 2.5)
              : null,
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppColors.shadowBlack,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  )
                ]
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$count Tasks',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
