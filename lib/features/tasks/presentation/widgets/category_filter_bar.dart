import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/task.dart';

class CategoryFilterBar extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;
  final List<Task> allTasks;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.allTasks,
  });

  int _getCount(String? categoryName) {
    if (categoryName == null) {
      return allTasks.where((t) => !t.isCompleted).length;
    }
    return allTasks
        .where((t) =>
            !t.isCompleted &&
            t.category.toLowerCase() == categoryName.toLowerCase())
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.defaultCategories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" Chip
            final isSelected = selectedCategory == null;
            final count = _getCount(null);
            return _buildChip(
              context: context,
              label: 'All',
              icon: Icons.grid_view_rounded,
              color: AppColors.primary,
              count: count,
              isSelected: isSelected,
              onTap: () => onCategorySelected(null),
              isDark: isDark,
            );
          }

          final cat = AppConstants.defaultCategories[index - 1];
          final catName = cat['name'] as String;
          final catIcon = cat['icon'] as IconData;
          final catColor = cat['color'] as Color;
          final isSelected =
              selectedCategory?.toLowerCase() == catName.toLowerCase();
          final count = _getCount(catName);

          return _buildChip(
            context: context,
            label: catName,
            icon: catIcon,
            color: catColor,
            count: count,
            isSelected: isSelected,
            onTap: () => onCategorySelected(isSelected ? null : catName),
            isDark: isDark,
          );
        },
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : (isDark
                          ? const Color(0xFF2A2F45)
                          : const Color(0xFFE4E7F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
