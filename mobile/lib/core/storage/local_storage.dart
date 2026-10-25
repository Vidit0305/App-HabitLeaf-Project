import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../utils/date_formatter.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();

    // 1. Ensure persistent installation ID
    if (getInstallationId().isEmpty) {
      final newId = 'inst_${const Uuid().v4()}';
      await _prefs!.setString(AppConstants.keyInstallationId, newId);
    }

    // 2. Ensure initial seed data exists so the app works 100% offline immediately
    await _seedInitialDataIfNeeded();
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
    // Re-seed default habits on clean slate
    await _seedInitialDataIfNeeded();
  }

  // Seed default habits, completions, settings, and notifications
  static Future<void> _seedInitialDataIfNeeded() async {
    if (_prefs == null) return;

    final existingHabits = _prefs!.getString(AppConstants.keyCachedHabits);
    if (existingHabits == null || existingHabits.trim().isEmpty || existingHabits == '[]') {
      final now = DateTime.now();
      final todayKey = DateFormatter.toDateKey(now);
      final yesterdayKey = DateFormatter.toDateKey(now.subtract(const Duration(days: 1)));
      final twoDaysAgoKey = DateFormatter.toDateKey(now.subtract(const Duration(days: 2)));
      final threeDaysAgoKey = DateFormatter.toDateKey(now.subtract(const Duration(days: 3)));

      final defaultHabits = [
        {
          '_id': 'seed_habit_1',
          'name': 'Morning Hydration',
          'description': 'Drink 2L of water throughout the day for vitality',
          'icon': 'water_drop',
          'color': '#10B981',
          'category': 'Health',
          'habitType': 'measurable',
          'targetValue': 2000.0,
          'targetUnit': 'ml',
          'frequency': 'every_day',
          'selectedWeekdays': [1, 2, 3, 4, 5, 6, 7],
          'startDate': now.subtract(const Duration(days: 14)).toIso8601String(),
          'reminderEnabled': true,
          'reminderTime': '08:00',
          'isArchived': false,
          'currentStreak': 4,
          'longestStreak': 9,
          'isCompletedToday': true,
          'todayCompletedValue': 2000.0,
        },
        {
          '_id': 'seed_habit_2',
          'name': 'Read 15 Pages',
          'description': 'Daily learning & personal growth reading session',
          'icon': 'menu_book',
          'color': '#059669',
          'category': 'Learning',
          'habitType': 'measurable',
          'targetValue': 15.0,
          'targetUnit': 'pages',
          'frequency': 'every_day',
          'selectedWeekdays': [1, 2, 3, 4, 5, 6, 7],
          'startDate': now.subtract(const Duration(days: 20)).toIso8601String(),
          'reminderEnabled': true,
          'reminderTime': '21:00',
          'isArchived': false,
          'currentStreak': 3,
          'longestStreak': 12,
          'isCompletedToday': false,
          'todayCompletedValue': 0.0,
        },
        {
          '_id': 'seed_habit_3',
          'name': 'Workout & Stretch',
          'description': 'Full body workout, movement, or yoga stretching',
          'icon': 'fitness_center',
          'color': '#0D9488',
          'category': 'Fitness',
          'habitType': 'measurable',
          'targetValue': 30.0,
          'targetUnit': 'mins',
          'frequency': 'every_day',
          'selectedWeekdays': [1, 2, 3, 4, 5, 6, 7],
          'startDate': now.subtract(const Duration(days: 10)).toIso8601String(),
          'reminderEnabled': true,
          'reminderTime': '07:30',
          'isArchived': false,
          'currentStreak': 2,
          'longestStreak': 6,
          'isCompletedToday': false,
          'todayCompletedValue': 0.0,
        },
        {
          '_id': 'seed_habit_4',
          'name': 'Mindful Meditation',
          'description': 'Calm mindfulness breathing session to recharge',
          'icon': 'self_improvement',
          'color': '#14B8A6',
          'category': 'Mindfulness',
          'habitType': 'measurable',
          'targetValue': 10.0,
          'targetUnit': 'mins',
          'frequency': 'every_day',
          'selectedWeekdays': [1, 2, 3, 4, 5, 6, 7],
          'startDate': now.subtract(const Duration(days: 15)).toIso8601String(),
          'reminderEnabled': false,
          'reminderTime': '22:00',
          'isArchived': false,
          'currentStreak': 5,
          'longestStreak': 14,
          'isCompletedToday': true,
          'todayCompletedValue': 10.0,
        },
        {
          '_id': 'seed_habit_5',
          'name': 'Deep Focus Session',
          'description': 'Undivided deep work on highest-impact project',
          'icon': 'laptop',
          'color': '#047857',
          'category': 'Productivity',
          'habitType': 'completion',
          'targetValue': 1.0,
          'targetUnit': 'times',
          'frequency': 'selected_weekdays',
          'selectedWeekdays': [1, 2, 3, 4, 5],
          'startDate': now.subtract(const Duration(days: 30)).toIso8601String(),
          'reminderEnabled': true,
          'reminderTime': '10:00',
          'isArchived': false,
          'currentStreak': 5,
          'longestStreak': 10,
          'isCompletedToday': false,
          'todayCompletedValue': 0.0,
        },
      ];

      await _prefs!.setString(AppConstants.keyCachedHabits, jsonEncode(defaultHabits));

      // Seed initial completion logs
      final initialCompletions = [
        {
          'habitId': 'seed_habit_1',
          'dateKey': todayKey,
          'status': 'completed',
          'completedValue': 2000.0,
          'notes': 'Completed early morning hydration',
        },
        {
          'habitId': 'seed_habit_1',
          'dateKey': yesterdayKey,
          'status': 'completed',
          'completedValue': 2000.0,
        },
        {
          'habitId': 'seed_habit_1',
          'dateKey': twoDaysAgoKey,
          'status': 'completed',
          'completedValue': 2000.0,
        },
        {
          'habitId': 'seed_habit_1',
          'dateKey': threeDaysAgoKey,
          'status': 'completed',
          'completedValue': 2000.0,
        },
        {
          'habitId': 'seed_habit_4',
          'dateKey': todayKey,
          'status': 'completed',
          'completedValue': 10.0,
          'notes': 'Felt very energized',
        },
        {
          'habitId': 'seed_habit_4',
          'dateKey': yesterdayKey,
          'status': 'completed',
          'completedValue': 10.0,
        },
        {
          'habitId': 'seed_habit_4',
          'dateKey': twoDaysAgoKey,
          'status': 'completed',
          'completedValue': 10.0,
        },
        {
          'habitId': 'seed_habit_2',
          'dateKey': yesterdayKey,
          'status': 'completed',
          'completedValue': 15.0,
        },
        {
          'habitId': 'seed_habit_3',
          'dateKey': yesterdayKey,
          'status': 'completed',
          'completedValue': 30.0,
        },
        {
          'habitId': 'seed_habit_5',
          'dateKey': yesterdayKey,
          'status': 'completed',
          'completedValue': 1.0,
        },
      ];
      await _prefs!.setString(AppConstants.keyCachedCompletions, jsonEncode(initialCompletions));
    }

    // Seed default settings if missing
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

    // Seed default notifications if missing
    final existingNotifications = _prefs!.getString(AppConstants.keyCachedNotifications);
    if (existingNotifications == null || existingNotifications.trim().isEmpty) {
      final now = DateTime.now();
      final defaultNotifications = [
        {
          '_id': 'notif_welcome',
          'type': 'system',
          'title': 'Welcome to Habit Tracker! 🌿',
          'message': 'Welcome aboard! Track your daily habits, build streaks, and achieve your goals with ease.',
          'status': 'read',
          'createdAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
        },
        {
          '_id': 'notif_streak',
          'type': 'streak_milestone',
          'title': 'Streak Milestone Unlocked! ⭐',
          'message': 'You completed your Morning Hydration habit and reached a 4-day streak! Keep up the momentum.',
          'status': 'delivered',
          'createdAt': now.subtract(const Duration(minutes: 45)).toIso8601String(),
        },
        {
          '_id': 'notif_reminder',
          'type': 'reminder',
          'title': 'Daily Habit Reminder',
          'message': 'Don\'t forget to complete your Read 15 Pages and Workout habits today!',
          'status': 'delivered',
          'createdAt': now.subtract(const Duration(minutes: 10)).toIso8601String(),
        },
      ];
      await _prefs!.setString(AppConstants.keyCachedNotifications, jsonEncode(defaultNotifications));
    }
  }
}
