import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000/api';
    }
    try {
      if (Platform.isAndroid) {
        // 10.0.2.2 points to host machine from Android Emulator
        // If testing on real physical device via adb reverse, 127.0.0.1 also works
        return 'http://10.0.2.2:5000/api';
      }
    } catch (_) {}
    return 'http://127.0.0.1:5000/api';
  }

  // Endpoints
  static const String health = '/health';
  static const String habits = '/habits';
  static const String completions = '/completions';
  static const String completionsUndo = '/completions/undo';
  static const String statisticsSummary = '/statistics/summary';
  static const String statisticsTrends = '/statistics/trends';
  static const String statisticsCalendar = '/statistics/calendar';
  static const String notifications = '/notifications';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String settings = '/settings';
  static const String settingsReset = '/settings/reset';
  static const String backupExport = '/backup/export';
  static const String backupCsv = '/backup/csv';
  static const String backupImport = '/backup/import';
}
