import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CustomCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final double size;

  const CustomCheckbox({
    super.key,
    required this.isChecked,
    required this.onChanged,
    this.activeColor = AppColors.primary,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isChecked ? activeColor : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isChecked
                ? activeColor
                : AppColors.darkTextMuted.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: isChecked
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: isChecked
            ? Center(
                child: Icon(
                  Icons.check_rounded,
                  size: size * 0.65,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}
