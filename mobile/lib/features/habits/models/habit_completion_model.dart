class HabitCompletionModel {
  final String id;
  final String habitId;
  final String dateKey;
  final String status; // 'completed', 'partial', 'skipped'
  final double completedValue;
  final double targetValueSnapshot;
  final String habitNameSnapshot;
  final String notes;
  final DateTime completedAt;

  HabitCompletionModel({
    required this.id,
    required this.habitId,
    required this.dateKey,
    this.status = 'completed',
    this.completedValue = 1.0,
    this.targetValueSnapshot = 1.0,
    this.habitNameSnapshot = '',
    this.notes = '',
    required this.completedAt,
  });

  bool get isCompleted => status == 'completed' || completedValue >= targetValueSnapshot;

  factory HabitCompletionModel.fromJson(Map<String, dynamic> json) {
    return HabitCompletionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      habitId: json['habitId'] is Map
          ? (json['habitId']['_id']?.toString() ?? '')
          : json['habitId']?.toString() ?? '',
      dateKey: json['dateKey']?.toString() ?? '',
      status: json['status']?.toString() ?? 'completed',
      completedValue: (json['completedValue'] as num?)?.toDouble() ?? 1.0,
      targetValueSnapshot: (json['targetValueSnapshot'] as num?)?.toDouble() ?? 1.0,
      habitNameSnapshot: json['habitNameSnapshot']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'habitId': habitId,
      'dateKey': dateKey,
      'status': status,
      'completedValue': completedValue,
      'targetValueSnapshot': targetValueSnapshot,
      'habitNameSnapshot': habitNameSnapshot,
      'notes': notes,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}
