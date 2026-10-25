class StatisticsSummary {
  final int completedToday;
  final int pendingToday;
  final int totalScheduledToday;
  final int completionPercentage;
  final int currentOverallStreak;
  final int longestOverallStreak;
  final int totalCompletions;
  final int overallCompletionRate;
  final Map<String, dynamic>? mostConsistentHabit;
  final Map<String, dynamic>? leastConsistentHabit;
  final int activeHabitsCount;

  StatisticsSummary({
    this.completedToday = 0,
    this.pendingToday = 0,
    this.totalScheduledToday = 0,
    this.completionPercentage = 0,
    this.currentOverallStreak = 0,
    this.longestOverallStreak = 0,
    this.totalCompletions = 0,
    this.overallCompletionRate = 0,
    this.mostConsistentHabit,
    this.leastConsistentHabit,
    this.activeHabitsCount = 0,
  });

  factory StatisticsSummary.fromJson(Map<String, dynamic> json) {
    final today = json['today'] as Map<String, dynamic>? ?? {};
    final streaks = json['streaks'] as Map<String, dynamic>? ?? {};

    return StatisticsSummary(
      completedToday: (today['completedCount'] as num?)?.toInt() ?? 0,
      pendingToday: (today['pendingCount'] as num?)?.toInt() ?? 0,
      totalScheduledToday: (today['totalScheduled'] as num?)?.toInt() ?? 0,
      completionPercentage: (today['percentage'] as num?)?.toInt() ?? 0,
      currentOverallStreak: (streaks['currentOverallStreak'] as num?)?.toInt() ?? 0,
      longestOverallStreak: (streaks['longestOverallStreak'] as num?)?.toInt() ?? 0,
      totalCompletions: (json['totalCompletions'] as num?)?.toInt() ?? 0,
      overallCompletionRate: (json['overallCompletionRate'] as num?)?.toInt() ?? 0,
      mostConsistentHabit: json['mostConsistentHabit'] as Map<String, dynamic>?,
      leastConsistentHabit: json['leastConsistentHabit'] as Map<String, dynamic>?,
      activeHabitsCount: (json['activeHabitsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class DayTrendItem {
  final String dateKey;
  final String dayLabel;
  final int scheduled;
  final int completed;
  final int percentage;

  DayTrendItem({
    required this.dateKey,
    required this.dayLabel,
    required this.scheduled,
    required this.completed,
    required this.percentage,
  });

  factory DayTrendItem.fromJson(Map<String, dynamic> json) {
    return DayTrendItem(
      dateKey: json['dateKey']?.toString() ?? '',
      dayLabel: json['dayLabel']?.toString() ?? '',
      scheduled: (json['scheduled'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
    );
  }
}

class WeeklyTrendItem {
  final String weekLabel;
  final int scheduled;
  final int completed;
  final int percentage;

  WeeklyTrendItem({
    required this.weekLabel,
    required this.scheduled,
    required this.completed,
    required this.percentage,
  });

  factory WeeklyTrendItem.fromJson(Map<String, dynamic> json) {
    return WeeklyTrendItem(
      weekLabel: json['weekLabel']?.toString() ?? '',
      scheduled: (json['scheduled'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
    );
  }
}

class MonthlyTrendItem {
  final String monthLabel;
  final int year;
  final int scheduled;
  final int completed;
  final int percentage;

  MonthlyTrendItem({
    required this.monthLabel,
    required this.year,
    required this.scheduled,
    required this.completed,
    required this.percentage,
  });

  factory MonthlyTrendItem.fromJson(Map<String, dynamic> json) {
    return MonthlyTrendItem(
      monthLabel: json['monthLabel']?.toString() ?? '',
      year: (json['year'] as num?)?.toInt() ?? 2026,
      scheduled: (json['scheduled'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
    );
  }
}

class HabitComparisonItem {
  final String habitId;
  final String name;
  final String color;
  final String icon;
  final int scheduledCount;
  final int completedCount;
  final int percentage;

  HabitComparisonItem({
    required this.habitId,
    required this.name,
    required this.color,
    required this.icon,
    required this.scheduledCount,
    required this.completedCount,
    required this.percentage,
  });

  factory HabitComparisonItem.fromJson(Map<String, dynamic> json) {
    return HabitComparisonItem(
      habitId: json['habitId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      color: json['color']?.toString() ?? '#2563EB',
      icon: json['icon']?.toString() ?? 'check_circle',
      scheduledCount: (json['scheduledCount'] as num?)?.toInt() ?? 0,
      completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
    );
  }
}

class CalendarDayItem {
  final String dateKey;
  final int day;
  final int dayOfWeek;
  final int scheduledCount;
  final int completedCount;
  final int percentage;
  final String intensity; // 'unscheduled', 'none', 'partial', 'full'
  final List<dynamic> habits;

  CalendarDayItem({
    required this.dateKey,
    required this.day,
    required this.dayOfWeek,
    required this.scheduledCount,
    required this.completedCount,
    required this.percentage,
    required this.intensity,
    required this.habits,
  });

  factory CalendarDayItem.fromJson(Map<String, dynamic> json) {
    return CalendarDayItem(
      dateKey: json['dateKey']?.toString() ?? '',
      day: (json['day'] as num?)?.toInt() ?? 1,
      dayOfWeek: (json['dayOfWeek'] as num?)?.toInt() ?? 0,
      scheduledCount: (json['scheduledCount'] as num?)?.toInt() ?? 0,
      completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
      intensity: json['intensity']?.toString() ?? 'unscheduled',
      habits: json['habits'] is List ? json['habits'] as List : [],
    );
  }
}
