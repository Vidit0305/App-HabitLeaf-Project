class ApiConstants {
  // Support local development on physical Android via adb reverse, Wi-Fi LAN IP, and local loopback
  static String get baseUrl {
    // 127.0.0.1 routes instantly via adb reverse tcp:5000 tcp:5000 on physical device and localhost
    return 'http://127.0.0.1:5000/api';
  }

  static const String lanBaseUrl = 'http://192.168.1.19:5000/api';

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
