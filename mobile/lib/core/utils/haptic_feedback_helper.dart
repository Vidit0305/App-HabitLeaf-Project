import 'package:flutter/services.dart';

class HapticFeedbackHelper {
  /// Subtle click for tab bar selections, filter chips, radio choices
  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Light tactile feedback for standard button taps, icon buttons, list tile presses
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Medium tactile impact for completing a habit or confirming a modal
  static Future<void> medium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Heavy tactile impact for destructive actions (delete, reset)
  static Future<void> heavy() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Premium double-pulse celebration vibration for completing a habit or milestone
  static Future<void> success() async {
    try {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 70));
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }
}
