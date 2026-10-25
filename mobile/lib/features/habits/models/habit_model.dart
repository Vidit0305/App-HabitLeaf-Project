class HabitModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final String category;
  final String habitType; // 'completion' or 'measurable'
  final double targetValue;
  final String targetUnit;
  final String frequency; // 'every_day' or 'selected_weekdays'
  final List<int> selectedWeekdays; // 1 = Mon ... 7 = Sun
  final DateTime startDate;
  final DateTime? endDate;
  final bool reminderEnabled;
  final String reminderTime;
  final String reminderType; // 'specific_time' or 'interval'
  final int reminderIntervalMinutes; // 5, 10, 15, 30, 60, etc.
  final bool isArchived;
  final int currentStreak;
  final int longestStreak;
  final bool isCompletedToday;
  final double todayCompletedValue;

  HabitModel({
    required this.id,
    required this.name,
    this.description = '',
    this.icon = 'track_changes',
    this.color = '#10B981',
    this.category = 'Health',
    this.habitType = 'completion',
    this.targetValue = 1.0,
    this.targetUnit = 'times',
    this.frequency = 'every_day',
    this.selectedWeekdays = const [1, 2, 3, 4, 5, 6, 7],
    required this.startDate,
    this.endDate,
    this.reminderEnabled = false,
    this.reminderTime = '09:00',
    this.reminderType = 'specific_time',
    this.reminderIntervalMinutes = 15,
    this.isArchived = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.isCompletedToday = false,
    this.todayCompletedValue = 0.0,
  });

  bool get isMeasurable => habitType == 'measurable';

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    List<int> parseWeekdays(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => (e as num).toInt()).toList();
      }
      return [1, 2, 3, 4, 5, 6, 7];
    }

    final todayComp = json['todayCompletion'] as Map<String, dynamic>?;
    final compValue = todayComp != null
        ? ((todayComp['completedValue'] as num?)?.toDouble() ?? 0.0)
        : (json['todayCompletedValue'] as num?)?.toDouble() ?? 0.0;

    return HabitModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'track_changes',
      color: json['color']?.toString() ?? '#10B981',
      category: json['category']?.toString() ?? 'Health',
      habitType: json['habitType']?.toString() ?? 'completion',
      targetValue: (json['targetValue'] as num?)?.toDouble() ?? 1.0,
      targetUnit: json['targetUnit']?.toString() ?? 'times',
      frequency: json['frequency']?.toString() ?? 'every_day',
      selectedWeekdays: parseWeekdays(json['selectedWeekdays']),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      reminderEnabled: json['reminderEnabled'] == true,
      reminderTime: json['reminderTime']?.toString() ?? '09:00',
      reminderType: json['reminderType']?.toString() ?? 'specific_time',
      reminderIntervalMinutes: (json['reminderIntervalMinutes'] as num?)?.toInt() ?? 15,
      isArchived: json['isArchived'] == true,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      isCompletedToday: json['isCompletedToday'] == true,
      todayCompletedValue: compValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'category': category,
      'habitType': habitType,
      'targetValue': targetValue,
      'targetUnit': targetUnit,
      'frequency': frequency,
      'selectedWeekdays': selectedWeekdays,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
      'reminderType': reminderType,
      'reminderIntervalMinutes': reminderIntervalMinutes,
      'isArchived': isArchived,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'isCompletedToday': isCompletedToday,
      'todayCompletedValue': todayCompletedValue,
    };
  }

  HabitModel copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    String? category,
    String? habitType,
    double? targetValue,
    String? targetUnit,
    String? frequency,
    List<int>? selectedWeekdays,
    DateTime? startDate,
    DateTime? endDate,
    bool? reminderEnabled,
    String? reminderTime,
    String? reminderType,
    int? reminderIntervalMinutes,
    bool? isArchived,
    int? currentStreak,
    int? longestStreak,
    bool? isCompletedToday,
    double? todayCompletedValue,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      habitType: habitType ?? this.habitType,
      targetValue: targetValue ?? this.targetValue,
      targetUnit: targetUnit ?? this.targetUnit,
      frequency: frequency ?? this.frequency,
      selectedWeekdays: selectedWeekdays ?? this.selectedWeekdays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderType: reminderType ?? this.reminderType,
      reminderIntervalMinutes: reminderIntervalMinutes ?? this.reminderIntervalMinutes,
      isArchived: isArchived ?? this.isArchived,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      todayCompletedValue: todayCompletedValue ?? this.todayCompletedValue,
    );
  }
}
