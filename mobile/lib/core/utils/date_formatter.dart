import 'package:intl/intl.dart';

class DateFormatter {
  static String toDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime fromDateKey(String dateKey) {
    return DateFormat('yyyy-MM-dd').parse(dateKey);
  }

  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String getGreeting(String name) {
    final hour = DateTime.now().hour;
    String timeGreeting;
    if (hour < 12) {
      timeGreeting = 'Good Morning';
    } else if (hour < 17) {
      timeGreeting = 'Good Afternoon';
    } else {
      timeGreeting = 'Good Evening';
    }
    return '$timeGreeting, $name';
  }

  static String weekdayName(int dayIndex) {
    // 1 = Monday ... 7 = Sunday
    switch (dayIndex) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Standardizes any dynamic date value (ISO 8601 string, DateTime, or dateKey) into standard 'yyyy-MM-dd' format.
  static String? normalizeDateKey(dynamic rawDate) {
    if (rawDate == null) return null;
    if (rawDate is DateTime) return toDateKey(rawDate);
    final str = rawDate.toString().trim();
    if (str.isEmpty) return null;
    if (str.length >= 10 && RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(str)) {
      return str.substring(0, 10);
    }
    try {
      final parsed = DateTime.parse(str);
      return toDateKey(parsed);
    } catch (_) {
      return null;
    }
  }
}
