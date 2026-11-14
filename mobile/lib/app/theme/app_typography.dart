import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static const String fontFamily = 'Inter';

  // Base Adaptive Typography (Inherits ambient theme text color by default)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  // Helper getters for explicit theme awareness
  static TextStyle getDisplayLarge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return displayLarge.copyWith(color: isDark ? AppColors.textLight : AppColors.textDarkNavy);
  }

  static TextStyle getDisplayMedium(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return displayMedium.copyWith(color: isDark ? AppColors.textLight : AppColors.textDarkNavy);
  }

  static TextStyle getTitleLarge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return titleLarge.copyWith(color: isDark ? AppColors.textLight : AppColors.textDarkNavy);
  }

  static TextStyle getTitleMedium(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return titleMedium.copyWith(color: isDark ? AppColors.textLight : AppColors.textDarkNavy);
  }

  static TextStyle getBodyLarge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return bodyLarge.copyWith(color: isDark ? AppColors.textLight : AppColors.textDarkNavy);
  }

  static TextStyle getBodyMedium(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return bodyMedium.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);
  }

  static TextStyle getBodySmall(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textMuted);
  }
}
