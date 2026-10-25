class SettingsModel {
  final String displayName;
  final String avatarReference;
  final String themeMode; // 'light', 'dark', 'system'
  final String timeFormat; // '12h', '24h'
  final String firstDayOfWeek; // 'monday', 'sunday'
  final bool defaultReminderEnabled;
  final bool dailySummaryEnabled;
  final String timezone;

  SettingsModel({
    this.displayName = 'Alex',
    this.avatarReference = 'avatar_1',
    this.themeMode = 'system',
    this.timeFormat = '12h',
    this.firstDayOfWeek = 'monday',
    this.defaultReminderEnabled = true,
    this.dailySummaryEnabled = true,
    this.timezone = 'UTC',
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      displayName: json['displayName']?.toString() ?? 'Alex',
      avatarReference: json['avatarReference']?.toString() ?? 'avatar_1',
      themeMode: json['themeMode']?.toString() ?? 'system',
      timeFormat: json['timeFormat']?.toString() ?? '12h',
      firstDayOfWeek: json['firstDayOfWeek']?.toString() ?? 'monday',
      defaultReminderEnabled: json['defaultReminderEnabled'] ?? true,
      dailySummaryEnabled: json['dailySummaryEnabled'] ?? true,
      timezone: json['timezone']?.toString() ?? 'UTC',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'avatarReference': avatarReference,
      'themeMode': themeMode,
      'timeFormat': timeFormat,
      'firstDayOfWeek': firstDayOfWeek,
      'defaultReminderEnabled': defaultReminderEnabled,
      'dailySummaryEnabled': dailySummaryEnabled,
      'timezone': timezone,
    };
  }

  SettingsModel copyWith({
    String? displayName,
    String? avatarReference,
    String? themeMode,
    String? timeFormat,
    String? firstDayOfWeek,
    bool? defaultReminderEnabled,
    bool? dailySummaryEnabled,
    String? timezone,
  }) {
    return SettingsModel(
      displayName: displayName ?? this.displayName,
      avatarReference: avatarReference ?? this.avatarReference,
      themeMode: themeMode ?? this.themeMode,
      timeFormat: timeFormat ?? this.timeFormat,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      defaultReminderEnabled: defaultReminderEnabled ?? this.defaultReminderEnabled,
      dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
      timezone: timezone ?? this.timezone,
    );
  }
}
