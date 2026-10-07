import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum TaskPriority {
  urgent(label: 'Urgent', color: AppColors.priorityUrgent, weight: 4),
  high(label: 'High', color: AppColors.priorityHigh, weight: 3),
  medium(label: 'Medium', color: AppColors.priorityMedium, weight: 2),
  low(label: 'Low', color: AppColors.priorityLow, weight: 1);

  final String label;
  final Color color;
  final int weight;

  const TaskPriority({
    required this.label,
    required this.color,
    required this.weight,
  });

  static TaskPriority fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'urgent':
        return TaskPriority.urgent;
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      case 'low':
      default:
        return TaskPriority.low;
    }
  }
}
