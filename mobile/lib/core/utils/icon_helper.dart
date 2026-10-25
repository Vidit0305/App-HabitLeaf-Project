import 'package:flutter/material.dart';

class IconHelper {
  static const Map<String, IconData> availableIcons = {
    'track_changes': Icons.track_changes_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'water_drop': Icons.water_drop_rounded,
    'menu_book': Icons.menu_book_rounded,
    'self_improvement': Icons.self_improvement_rounded,
    'spa': Icons.spa_rounded,
    'eco': Icons.eco_rounded,
    'bolt': Icons.bolt_rounded,
    'directions_run': Icons.directions_run_rounded,
    'sports_gymnastics': Icons.sports_gymnastics_rounded,
    'pool': Icons.pool_rounded,
    'hiking': Icons.hiking_rounded,
    'bedtime': Icons.bedtime_rounded,
    'wb_sunny': Icons.wb_sunny_rounded,
    'timer': Icons.timer_rounded,
    'auto_awesome': Icons.auto_awesome_rounded,
    'laptop_mac': Icons.laptop_mac_rounded,
    'code': Icons.code_rounded,
    'lightbulb': Icons.lightbulb_rounded,
    'school': Icons.school_rounded,
    'savings': Icons.savings_rounded,
    'wallet': Icons.account_balance_wallet_rounded,
    'favorite': Icons.favorite_rounded,
    'restaurant': Icons.restaurant_rounded,
    'local_cafe': Icons.local_cafe_rounded,
    'psychology': Icons.psychology_rounded,
    'brush': Icons.brush_rounded,
    'music_note': Icons.music_note_rounded,
  };

  static IconData getIcon(String? iconName) {
    if (iconName == null || !availableIcons.containsKey(iconName)) {
      return Icons.track_changes_rounded;
    }
    return availableIcons[iconName]!;
  }

  static Color parseColor(String? hexString, {Color fallback = const Color(0xFF10B981)}) {
    if (hexString == null || hexString.isEmpty) return fallback;
    try {
      final clean = hexString.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      } else if (clean.length == 8) {
        return Color(int.parse(clean, radix: 16));
      }
    } catch (_) {}
    return fallback;
  }
}
