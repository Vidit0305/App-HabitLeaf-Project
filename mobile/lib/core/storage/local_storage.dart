import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();

    // 1. Ensure persistent installation ID
    if (getInstallationId().isEmpty) {
      final newId = 'inst_${const Uuid().v4()}';
      await _prefs!.setString(AppConstants.keyInstallationId, newId);
    }

    // 2. Purge legacy fake/dummy seed habits if previously saved on device
    await _purgeLegacyDummyDataIfNeeded();

    // 3. Initialize default clean settings and collections
    await _initCleanDefaults();
  }

  static Future<void> _purgeLegacyDummyDataIfNeeded() async {
    if (_prefs == null) return;
    final cachedHabits = _prefs!.getString(AppConstants.keyCachedHabits);
    if (cachedHabits != null &&
        (cachedHabits.contains('seed_habit_') || cachedHabits.contains('Morning Hydration'))) {
      await _prefs!.remove(AppConstants.keyCachedHabits);
      await _prefs!.remove(AppConstants.keyCachedCompletions);
      await _prefs!.remove(AppConstants.keyCachedNotifications);
    }
  }

  static Future<void> _initCleanDefaults() async {
    if (_prefs == null) return;

    // Default clean habits list (empty - fully connected to live MongoDB)
    final existingHabits = _prefs!.getString(AppConstants.keyCachedHabits);
    if (existingHabits == null || existingHabits.trim().isEmpty) {
      await _prefs!.setString(AppConstants.keyCachedHabits, '[]');
    }

    // Default clean completions list
    final existingCompletions = _prefs!.getString(AppConstants.keyCachedCompletions);
    if (existingCompletions == null || existingCompletions.trim().isEmpty) {
      await _prefs!.setString(AppConstants.keyCachedCompletions, '[]');
    }

    // Default settings
    final existingSettings = _prefs!.getString(AppConstants.keyCachedSettings);
    if (existingSettings == null || existingSettings.trim().isEmpty) {
      final defaultSettings = {
        'displayName': 'Alex',
        'avatarReference': 'avatar_1',
        'themeMode': 'system',
        'timeFormat': '12h',
        'firstDayOfWeek': 'monday',
        'defaultReminderEnabled': true,
        'dailySummaryEnabled': true,
        'timezone': 'UTC',
      };
      await _prefs!.setString(AppConstants.keyCachedSettings, jsonEncode(defaultSettings));
    }

    // Clean notifications
    final existingNotifications = _prefs!.getString(AppConstants.keyCachedNotifications);
    if (existingNotifications == null || existingNotifications.trim().isEmpty) {
      final welcomeNotif = [
        {
          '_id': 'notif_welcome_${DateTime.now().millisecondsSinceEpoch}',
          'type': 'system',
          'title': 'Welcome to Habit Tracker! 🌿',
          'message': 'Your live database is connected. Add your first habit to begin building daily consistency!',
          'status': 'read',
          'createdAt': DateTime.now().toIso8601String(),
        }
      ];
      await _prefs!.setString(AppConstants.keyCachedNotifications, jsonEncode(welcomeNotif));
    }
  }

  static String getInstallationId() {
    return _prefs?.getString(AppConstants.keyInstallationId) ?? '';
  }

  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  static Future<void> clearAll() async {
    final instId = getInstallationId();
    await _prefs?.clear();
    if (instId.isNotEmpty) {
      await _prefs!.setString(AppConstants.keyInstallationId, instId);
    }
    await _initCleanDefaults();
  }
}
