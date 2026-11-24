import '../utils/date_formatter.dart';
import '../../features/habits/models/habit_model.dart';

class StreakResult {
  final int currentStreak;
  final int longestStreak;

  const StreakResult({
    required this.currentStreak,
    required this.longestStreak,
  });
}

class StreakCalculator {
  /// Checks whether a habit is scheduled to be performed on a specific calendar date.
  static bool isHabitScheduledOnDate(HabitModel habit, DateTime date) {
    final compDate = DateTime(date.year, date.month, date.day);
    final startDate = DateTime(
      habit.startDate.year,
      habit.startDate.month,
      habit.startDate.day,
    );

    if (compDate.isBefore(startDate)) {
      return false;
    }

    if (habit.endDate != null) {
      final endDate = DateTime(
        habit.endDate!.year,
        habit.endDate!.month,
        habit.endDate!.day,
        23,
        59,
        59,
      );
      if (compDate.isAfter(endDate)) {
        return false;
      }
    }

    if (habit.frequency == 'every_day') {
      return true;
    }

    if (habit.frequency == 'selected_weekdays') {
      // DateTime.weekday: 1 = Monday ... 7 = Sunday
      return habit.selectedWeekdays.contains(compDate.weekday);
    }

    return true;
  }

  /// Calculates the current and longest streak for a habit dynamically based on its
  /// scheduled days and actual completion history.
  static StreakResult calculateHabitStreak(
    HabitModel habit,
    Map<String, Map<String, dynamic>> completionsByDate, [
    DateTime? now,
  ]) {
    final currentNow = now ?? DateTime.now();
    final today = DateTime(currentNow.year, currentNow.month, currentNow.day);
    final todayKey = DateFormatter.toDateKey(today);

    final start = DateTime(
      habit.startDate.year,
      habit.startDate.month,
      habit.startDate.day,
    );

    // Collect all scheduled dates from startDate up to today in chronological order
    final scheduledDateKeys = <String>[];
    var curr = start;
    while (!curr.isAfter(today)) {
      if (isHabitScheduledOnDate(habit, curr)) {
        scheduledDateKeys.add(DateFormatter.toDateKey(curr));
      }
      curr = curr.add(const Duration(days: 1));
    }

    if (scheduledDateKeys.isEmpty) {
      return const StreakResult(currentStreak: 0, longestStreak: 0);
    }

    // 1. Calculate longest streak historically
    int longestStreak = 0;
    int tempStreak = 0;

    for (final dateKey in scheduledDateKeys) {
      final comp = completionsByDate[dateKey];
      final isCompleted = comp != null &&
          (comp['status'] == 'completed' ||
              (habit.isMeasurable
                  ? ((comp['completedValue'] as num?)?.toDouble() ?? 0.0) >= habit.targetValue
                  : ((comp['completedValue'] as num?)?.toDouble() ?? 0.0) >= 1.0));

      if (isCompleted) {
        tempStreak += 1;
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
      } else {
        // If dateKey is today and not yet completed, don't break historical streak
        if (dateKey != todayKey) {
          tempStreak = 0;
        }
      }
    }

    // 2. Calculate current active streak (walking backwards)
    int currentStreak = 0;
    int startIndex = scheduledDateKeys.length - 1;

    final latestDateKey = scheduledDateKeys[startIndex];
    if (latestDateKey == todayKey) {
      final todayComp = completionsByDate[todayKey];
      final isTodayDone = todayComp != null &&
          (todayComp['status'] == 'completed' ||
              (habit.isMeasurable
                  ? ((todayComp['completedValue'] as num?)?.toDouble() ?? 0.0) >= habit.targetValue
                  : ((todayComp['completedValue'] as num?)?.toDouble() ?? 0.0) >= 1.0));

      if (isTodayDone) {
        currentStreak += 1;
        startIndex -= 1;
      } else {
        // Today is scheduled but not yet completed. It doesn't break yesterday's streak.
        startIndex -= 1;
      }
    }

    for (int i = startIndex; i >= 0; i--) {
      final dateKey = scheduledDateKeys[i];
      final comp = completionsByDate[dateKey];
      final isDone = comp != null &&
          (comp['status'] == 'completed' ||
              (habit.isMeasurable
                  ? ((comp['completedValue'] as num?)?.toDouble() ?? 0.0) >= habit.targetValue
                  : ((comp['completedValue'] as num?)?.toDouble() ?? 0.0) >= 1.0));

      if (isDone) {
        currentStreak += 1;
      } else {
        break; // Streak broken on a past scheduled day
      }
    }

    final maxStreak = longestStreak > currentStreak ? longestStreak : currentStreak;

    return StreakResult(
      currentStreak: currentStreak,
      longestStreak: maxStreak,
    );
  }
}
