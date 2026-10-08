import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class NeoBrutalist {
  /// Standard Neo-Brutalist card decoration with crisp outline and solid offset shadow.
  /// Automatically adapts to dark mode if [context] is provided.
  static BoxDecoration card({
    BuildContext? context,
    Color? backgroundColor,
    double borderRadius = 18.0,
    double borderWidth = 1.5,
    Offset shadowOffset = const Offset(0, 3.5),
    Color? borderColor,
    Color? shadowColor,
  }) {
    final isDark =
        context != null && Theme.of(context).brightness == Brightness.dark;
    final bg =
        backgroundColor ?? (isDark ? const Color(0xFF191C24) : Colors.white);
    final border =
        borderColor ?? (isDark ? const Color(0xFF2E3342) : AppColors.borderBlack);
    final shadow = shadowColor ??
        (isDark ? Colors.black.withValues(alpha: 0.6) : AppColors.shadowBlack);

    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: border, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: shadow,
          offset: shadowOffset,
          blurRadius: 0,
        ),
      ],
    );
  }

  /// Interactive pressable button decoration
  static BoxDecoration button({
    BuildContext? context,
    Color backgroundColor = AppColors.primary,
    double borderRadius = 30.0,
    double borderWidth = 1.5,
    bool isPressed = false,
  }) {
    final isDark =
        context != null && Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? Colors.black : AppColors.borderBlack;

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: border, width: borderWidth),
      boxShadow: isPressed
          ? []
          : [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.8)
                    : AppColors.shadowBlack,
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
    );
  }

  /// Input field decoration matching the screenshot
  static InputDecoration inputDecoration({
    BuildContext? context,
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final isDark =
        context != null && Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? const Color(0xFF191C24) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E3342) : AppColors.borderBlack;

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      filled: true,
      fillColor: fillColor,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
            color: isDark ? AppColors.primary : AppColors.borderBlack,
            width: 2.0),
      ),
    );
  }

  /// Small square icon button decoration (like back button, grid button, theme toggle, etc.)
  static BoxDecoration iconButton({
    BuildContext? context,
    Color? backgroundColor,
    double borderRadius = 14.0,
  }) {
    final isDark =
        context != null && Theme.of(context).brightness == Brightness.dark;
    final bg =
        backgroundColor ?? (isDark ? const Color(0xFF191C24) : Colors.white);
    final border = isDark ? const Color(0xFF2E3342) : AppColors.borderBlack;
    final shadow =
        isDark ? Colors.black.withValues(alpha: 0.6) : AppColors.shadowBlack;

    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: border, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: shadow,
          offset: const Offset(0, 2.5),
          blurRadius: 0,
        ),
      ],
    );
  }
}
