import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryGreenAccent,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreenAccent,
        secondary: AppColors.primaryEmerald,
        surface: AppColors.surfaceLight,
        error: AppColors.errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textDarkNavy,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.textDarkNavy, fontWeight: FontWeight.w800),
        displayMedium: TextStyle(color: AppColors.textDarkNavy, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: AppColors.textDarkNavy, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: AppColors.textDarkNavy, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: AppColors.textDarkNavy, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.textDarkNavy, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(color: AppColors.textDarkNavy, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: AppColors.primaryGreenAccent, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textDarkNavy),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textDarkNavy,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryGreenAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgLight,
        selectedColor: AppColors.primaryGreenAccent,
        labelStyle: const TextStyle(color: AppColors.textDarkNavy, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        side: const BorderSide(color: AppColors.borderLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        titleTextStyle: const TextStyle(color: AppColors.textDarkNavy, fontSize: 18, fontWeight: FontWeight.w700),
        contentTextStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        modalBackgroundColor: AppColors.surfaceLight,
      ),
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.textDarkNavy,
        iconColor: AppColors.primaryGreenAccent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreenAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreenAccent,
          side: const BorderSide(color: AppColors.primaryGreenAccent),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryGreenAccent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryEmerald,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryEmerald,
        secondary: AppColors.primaryGreenLight,
        surface: AppColors.surfaceDark,
        error: AppColors.errorRed,
        onPrimary: Colors.white,
        onSecondary: AppColors.bgDark,
        onSurface: AppColors.textLight,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w800),
        displayMedium: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: AppColors.textSecondaryDark, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(color: AppColors.textSecondaryDark, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: AppColors.primaryGreenLight, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(color: AppColors.textSecondaryDark, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textLight),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDarkElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryEmerald, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
        hintStyle: TextStyle(color: AppColors.textSecondaryDark.withOpacity(0.6)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDarkElevated,
        selectedColor: AppColors.primaryEmerald,
        disabledColor: AppColors.surfaceDark,
        labelStyle: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        side: const BorderSide(color: AppColors.borderDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        titleTextStyle: const TextStyle(color: AppColors.textLight, fontSize: 18, fontWeight: FontWeight.w700),
        contentTextStyle: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        modalBackgroundColor: AppColors.surfaceDark,
      ),
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.textLight,
        iconColor: AppColors.primaryGreenLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryEmerald,
          side: const BorderSide(color: AppColors.primaryEmerald),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryEmerald,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
