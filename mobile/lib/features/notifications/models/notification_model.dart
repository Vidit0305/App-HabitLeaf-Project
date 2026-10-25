class NotificationModel {
  final String id;
  final String type; // 'reminder', 'delivered', 'missed', 'summary', 'streak_milestone', 'system'
  final String title;
  final String message;
  final String? habitId;
  final String? habitName;
  final String? habitIcon;
  final String? habitColor;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final String status; // 'scheduled', 'delivered', 'read', 'dismissed', 'failed'
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    this.type = 'delivered',
    required this.title,
    required this.message,
    this.habitId,
    this.habitName,
    this.habitIcon,
    this.habitColor,
    this.deliveredAt,
    this.readAt,
    this.status = 'delivered',
    required this.createdAt,
  });

  bool get isRead => status == 'read';

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    String? hId;
    String? hName;
    String? hIcon;
    String? hColor;

    if (json['habitId'] is Map) {
      final h = json['habitId'] as Map<String, dynamic>;
      hId = h['_id']?.toString();
      hName = h['name']?.toString();
      hIcon = h['icon']?.toString();
      hColor = h['color']?.toString();
    } else if (json['habitId'] != null) {
      hId = json['habitId'].toString();
    }

    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'delivered',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      habitId: hId,
      habitName: hName,
      habitIcon: hIcon,
      habitColor: hColor,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.tryParse(json['deliveredAt'].toString())
          : null,
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'].toString())
          : null,
      status: json['status']?.toString() ?? 'delivered',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'title': title,
      'message': message,
      'habitId': habitId,
      'habitName': habitName,
      'habitIcon': habitIcon,
      'habitColor': habitColor,
      'deliveredAt': deliveredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
