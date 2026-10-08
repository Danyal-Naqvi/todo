import 'package:flutter/material.dart';

class AppColors {
  // Brand & Accent Colors (matching design screenshots)
  static const Color primary = Color(0xFFFA6551); // Coral / Salmon red
  static const Color primaryLight = Color(0xFFFF8B7A);
  static const Color primaryDark = Color(0xFFE0523E);
  static const Color accent = Color(0xFFFA6551);

  // Status Cards Colors (exact match to dashboard 2x2 grid)
  static const Color statusOnGoing = Color(0xFF4D86F7); // Blue
  static const Color statusInProcess = Color(0xFFF5B335); // Warm Amber / Yellow
  static const Color statusCompleted = Color(0xFF42BAAE); // Mint / Cyan
  static const Color statusCanceled = Color(0xFFF16565); // Coral Red

  // Neo-Brutalist Theme Colors
  static const Color bg = Color(0xFFF8F9FA); // Crisp clean canvas
  static const Color cardBg = Colors.white;
  static const Color borderBlack = Color(0xFF181A1F); // Crisp dark outline
  static const Color shadowBlack = Color(0xFF181A1F);

  // Text Colors
  static const Color textPrimary = Color(0xFF14171A);
  static const Color textSecondary = Color(0xFF65676B);
  static const Color textMuted = Color(0xFF9EA3AE);
  static const Color textLight = Colors.white;

  // Category / Chip Colors
  static const Color chipBg = Color(0xFFF1F3F6);
  static const Color chipBorder = Color(0xFFE4E7EB);
  static const Color chipSelected = Color(0xFF181A1F);

  // Priority Colors
  static const Color priorityUrgent = Color(0xFFF16565);
  static const Color priorityHigh = Color(0xFFF5B335);
  static const Color priorityMedium = Color(0xFF4D86F7);
  static const Color priorityLow = Color(0xFF42BAAE);

  // Backward-compatible category colors
  static const Color catWork = Color(0xFF4D86F7);
  static const Color catPersonal = Color(0xFFFA6551);
  static const Color catFitness = Color(0xFF42BAAE);
  static const Color catStudy = Color(0xFFF5B335);
  static const Color catFinance = Color(0xFF20BF6B);
  static const Color catIdeas = Color(0xFFA55EEA);

  // Backward compatibility with dark mode
  static const Color darkBg = Color(0xFF121418);
  static const Color darkSurface = Color(0xFF1B1E24);
  static const Color darkCard = Color(0xFF22262E);
  static const Color darkBorder = Color(0xFF2F343F);
  static const Color darkTextPrimary = Color(0xFFF5F6F8);
  static const Color darkTextSecondary = Color(0xFFA0A6B2);
  static const Color darkTextMuted = Color(0xFF6E7482);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Colors.white;
  static const Color lightBorder = Color(0xFF181A1F);
  static const Color lightTextPrimary = Color(0xFF14171A);
  static const Color lightTextSecondary = Color(0xFF65676B);
  static const Color lightTextMuted = Color(0xFF9EA3AE);
  static const Color secondary = Color(0xFF42BAAE);

  // Dynamic Theme Helpers
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color dynamicBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF0E1015) : bg;

  static Color dynamicCard(BuildContext context) =>
      isDark(context) ? const Color(0xFF191C24) : Colors.white;

  static Color dynamicSurface(BuildContext context) =>
      isDark(context) ? const Color(0xFF222632) : const Color(0xFFF1F3F6);

  static Color dynamicBorder(BuildContext context) =>
      isDark(context) ? const Color(0xFF2E3342) : borderBlack;

  static Color dynamicText(BuildContext context) =>
      isDark(context) ? darkTextPrimary : textPrimary;

  static Color dynamicSubtext(BuildContext context) =>
      isDark(context) ? darkTextSecondary : textSecondary;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFA6551), Color(0xFFFF8B7A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle warm surface gradient for highlighted cards.
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFF5F3), Colors.white],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fireGradient = LinearGradient(
    colors: [Color(0xFFF5B335), Color(0xFFFA6551)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
