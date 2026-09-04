import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Luxurious Emerald Green & Mint
  static const Color primaryEmerald = Color(0xFF10B981); // Emerald Green
  static const Color primaryGreenAccent = Color(0xFF059669); // Rich Deep Emerald
  static const Color primaryGreenDeep = Color(0xFF047857); // Dark Emerald
  static const Color primaryGreenDark = Color(0xFF064E3B); // Forest Deep Green
  static const Color primaryGreenLight = Color(0xFF34D399); // Vibrant Mint Light
  static const Color primaryGreenSoft = Color(0xFFD1FAE5); // Mint 100
  static const Color primaryGreenUltraSoft = Color(0xFFECFDF5); // Fresh Soft Tint

  // Compatibility aliases for seamless theme migration
  static const Color primaryRoyalBlue = Color(0xFF059669); // Now Emerald
  static const Color primaryBlueAccent = Color(0xFF10B981); // Now Emerald Accent
  static const Color skyBlue = Color(0xFF10B981); // Now Emerald
  static const Color skyBlueLight = Color(0xFF34D399); // Now Mint
  static const Color softBlueBackground = Color(0xFFECFDF5); // Fresh White-Green

  // Premium Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF047857), Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldCardGradient = LinearGradient(
    colors: [Color(0xFF065F46), Color(0xFF047857), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF065F46), Color(0xFF047857), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient streakGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGreenGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF0FDF4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Success & Completion states (Green)
  static const Color successGreen = Color(0xFF10B981);
  static const Color successGreenDark = Color(0xFF059669);
  static const Color successGreenLight = Color(0xFFD1FAE5);

  // Streak & Milestone (Warm Gold with Green harmony)
  static const Color streakOrange = Color(0xFF10B981);
  static const Color streakGold = Color(0xFF059669);
  static const Color streakLight = Color(0xFFECFDF5);

  // Neutral Colors - Light Theme (Pure Green & Crisp White)
  static const Color bgLight = Color(0xFFF7FAF8); // Crisp clean white-mint
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceLightElevated = Color(0xFFF0FDF4); // Soft Emerald Tint
  static const Color borderLight = Color(0xFFE2EFE6); // Elegant Mint Border
  static const Color textDarkNavy = Color(0xFF0A261D); // Deep Pine Charcoal
  static const Color textSecondary = Color(0xFF4A685E); // Sage Slate
  static const Color textMuted = Color(0xFF86A398); // Light Sage

  // Neutral Colors - Dark Theme (Deep Obsidian Forest)
  static const Color bgDark = Color(0xFF0B1410); // Obsidian Forest
  static const Color surfaceDark = Color(0xFF12221B); // Dark Emerald Slate
  static const Color surfaceDarkElevated = Color(0xFF1A3026); // Elevated Emerald Slate
  static const Color borderDark = Color(0xFF234235); // Dark Emerald Border
  static const Color textLight = Color(0xFFF2FBF6); // Crisp Clean White
  static const Color textSecondaryDark = Color(0xFF94B5A5); // Soft Mint Grey

  // Error / Warning
  static const Color errorRed = Color(0xFFEF4444);
  static const Color errorRedLight = Color(0xFFFEE2E2);

  // Curated Green-Harmonious Category Colors
  static const List<Color> categoryPalette = [
    Color(0xFF10B981), // Emerald
    Color(0xFF059669), // Forest Green
    Color(0xFF0D9488), // Teal
    Color(0xFF14B8A6), // Light Teal
    Color(0xFF22C55E), // Vibrant Green
    Color(0xFF84CC16), // Lime Green
    Color(0xFF047857), // Deep Jade
    Color(0xFF34D399), // Mint Green
  ];

  // Calendar Completion Indicators
  static const Color calendarCompleted = Color(0xFF10B981);
  static const Color calendarUncompleted = Color(0xFFFFFFFF);
}
