import 'package:flutter/material.dart';
import '../../domain/entities/task_priority.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool showLabel;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (priority) {
      case TaskPriority.urgent:
        icon = Icons.local_fire_department_rounded;
        break;
      case TaskPriority.high:
        icon = Icons.arrow_upward_rounded;
        break;
      case TaskPriority.medium:
        icon = Icons.remove_rounded;
        break;
      case TaskPriority.low:
        icon = Icons.arrow_downward_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 8.0 : 5.0,
        vertical: 3.5,
      ),
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: priority.color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: priority.color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              priority.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: priority.color,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
