import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/utils/date_formatter.dart';
import 'package:habit_tracker/core/utils/streak_calculator.dart';
import 'package:habit_tracker/features/habits/models/habit_model.dart';

void main() {
  group('StreakCalculator and Daily Reset Tests', () {
    test('Habit completed yesterday maintains streak today before completion', () {
      final now = DateTime(2026, 11, 24, 8, 30); // Tuesday morning
      final yesterdayKey = DateFormatter.toDateKey(now.subtract(const Duration(days: 1))); // 2026-11-23

      final habit = HabitModel(
        id: 'habit_test_1',
        name: 'Morning Run',
        startDate: DateTime(2026, 11, 20),
        frequency: 'every_day',
      );

      final completions = <String, Map<String, dynamic>>{
        yesterdayKey: {'status': 'completed', 'completedValue': 1.0},
      };

      final streak = StreakCalculator.calculateHabitStreak(habit, completions, now);

      // Streak should still be 1 (from yesterday), waiting for today's check
      expect(streak.currentStreak, 1);
      expect(streak.longestStreak, 1);
    });

    test('Habit completed yesterday and today increments streak', () {
      final now = DateTime(2026, 11, 24, 8, 30);
      final todayKey = DateFormatter.toDateKey(now); // 2026-11-24
      final yesterdayKey = DateFormatter.toDateKey(now.subtract(const Duration(days: 1))); // 2026-11-23

      final habit = HabitModel(
        id: 'habit_test_1',
        name: 'Morning Run',
        startDate: DateTime(2026, 11, 20),
        frequency: 'every_day',
      );

      final completions = <String, Map<String, dynamic>>{
        yesterdayKey: {'status': 'completed', 'completedValue': 1.0},
        todayKey: {'status': 'completed', 'completedValue': 1.0},
      };

      final streak = StreakCalculator.calculateHabitStreak(habit, completions, now);

      expect(streak.currentStreak, 2);
      expect(streak.longestStreak, 2);
    });

    test('Habit missed yesterday resets streak to 0 today', () {
      final now = DateTime(2026, 11, 24, 8, 30);
      final twoDaysAgoKey = DateFormatter.toDateKey(now.subtract(const Duration(days: 2))); // 2026-11-22

      final habit = HabitModel(
        id: 'habit_test_1',
        name: 'Morning Run',
        startDate: DateTime(2026, 11, 20),
        frequency: 'every_day',
      );

      // Completed 2 days ago, but missed yesterday
      final completions = <String, Map<String, dynamic>>{
        twoDaysAgoKey: {'status': 'completed', 'completedValue': 1.0},
      };

      final streak = StreakCalculator.calculateHabitStreak(habit, completions, now);

      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 1);
    });
  });
}
