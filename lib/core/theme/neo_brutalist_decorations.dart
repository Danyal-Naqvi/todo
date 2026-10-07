import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class NeoBrutalist {
  /// Standard Neo-Brutalist card decoration with crisp black outline and solid offset shadow
  static BoxDecoration card({
    Color backgroundColor = Colors.white,
    double borderRadius = 18.0,
    double borderWidth = 1.5,
    Offset shadowOffset = const Offset(0, 3.5),
    Color borderColor = AppColors.borderBlack,
    Color shadowColor = AppColors.shadowBlack,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          offset: shadowOffset,
          blurRadius: 0,
        ),
      ],
    );
  }

  /// Interactive pressable button decoration
  static BoxDecoration button({
    Color backgroundColor = AppColors.primary,
    double borderRadius = 30.0,
    double borderWidth = 1.5,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: AppColors.borderBlack, width: borderWidth),
      boxShadow: isPressed
          ? []
          : const [
              BoxShadow(
                color: AppColors.shadowBlack,
                offset: Offset(0, 3),
                blurRadius: 0,
              ),
            ],
    );
  }

  /// Input field decoration matching the screenshot
  static InputDecoration inputDecoration({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.borderBlack, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.borderBlack, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.borderBlack, width: 2.0),
      ),
    );
  }

  /// Small square icon button decoration (like back button, grid button, etc.)
  static BoxDecoration iconButton({
    Color backgroundColor = Colors.white,
    double borderRadius = 14.0,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: AppColors.borderBlack, width: 1.5),
      boxShadow: const [
        BoxShadow(
          color: AppColors.shadowBlack,
          offset: Offset(0, 2.5),
          blurRadius: 0,
        ),
      ],
    );
  }
}
