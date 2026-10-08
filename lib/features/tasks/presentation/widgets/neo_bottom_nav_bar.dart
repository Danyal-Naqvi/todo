import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class NeoBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;

  const NeoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14171E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF262B36) : const Color(0xFFF0F2F5),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Tab 0: Home
            _NavIconItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              isSelected: currentIndex == 0,
              onTap: () => onTabSelected(0),
            ),

            // Tab 1: Calendar / Schedule
            _NavIconItem(
              icon: Icons.calendar_month_outlined,
              activeIcon: Icons.calendar_month_rounded,
              isSelected: currentIndex == 1,
              onTap: () => onTabSelected(1),
            ),

            // Center + Action Button
            GestureDetector(
              onTap: onAddPressed,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x40FA6551),
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),

            // Tab 2: Focus & Timer (mapped to index 2)
            _NavIconItem(
              icon: Icons.timer_outlined,
              activeIcon: Icons.timer_rounded,
              isSelected: currentIndex == 2,
              onTap: () => onTabSelected(2),
            ),

            // Tab 3: Profile (mapped to index 3)
            _NavIconItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              isSelected: currentIndex == 3,
              onTap: () => onTabSelected(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIconItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavIconItem({
    required this.icon,
    required this.activeIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Icon(
          isSelected ? activeIcon : icon,
          size: 26,
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF6E7582) : const Color(0xFFFFAFA6)),
        ),
      ),
    );
  }
}
