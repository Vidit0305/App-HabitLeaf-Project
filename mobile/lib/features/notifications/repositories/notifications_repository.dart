import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../models/notification_model.dart';

class NotificationsRepository {
  final ApiClient apiClient;

  NotificationsRepository({required this.apiClient});

  List<NotificationModel> _getLocalNotifications() {
    final cached = LocalStorage.getString(AppConstants.keyCachedNotifications);
    if (cached == null || cached.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(cached) as List;
      return decoded.map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalNotifications(List<NotificationModel> list) async {
    final jsonList = list.map((n) => n.toJson()).toList();
    await LocalStorage.setString(AppConstants.keyCachedNotifications, jsonEncode(jsonList));
  }

  Future<NotificationModel> addNotification({
    required String title,
    required String message,
    String type = 'reminder',
    String? habitId,
    String? habitName,
    String? habitIcon,
    String? habitColor,
  }) async {
    final now = DateTime.now();
    final newNotif = NotificationModel(
      id: 'notif_${now.millisecondsSinceEpoch}',
      type: type,
      title: title,
      message: message,
      habitId: habitId,
      habitName: habitName,
      habitIcon: habitIcon,
      habitColor: habitColor,
      deliveredAt: now,
      status: 'delivered',
      createdAt: now,
    );

    final list = _getLocalNotifications();
    list.removeWhere((n) => n.id == newNotif.id);
    list.insert(0, newNotif);
    await _saveLocalNotifications(list);

    // Sync to backend in background
    Future(() async {
      try {
        await apiClient.post(
          ApiConstants.notifications,
          data: {
            'title': title,
            'message': message,
            'type': type,
            'habitId': ?habitId,
            'status': 'delivered',
            'deliveredAt': now.toIso8601String(),
          },
        );
      } catch (_) {}
    });

    return newNotif;
  }

  Future<Map<String, dynamic>> fetchNotifications({String? status}) async {
    // 1. Try fetching from server
    try {
      final query = <String, dynamic>{};
      if (status != null) query['status'] = status;
      final res = await apiClient
          .get(ApiConstants.notifications, queryParameters: query)
          .timeout(const Duration(seconds: 4));

      if (res != null && res['data'] is Map) {
        final serverList = (res['data']['notifications'] as List? ?? [])
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final localList = _getLocalNotifications();
        final serverIds = serverList.map((n) => n.id).toSet();
        // Keep any local-only notifications (e.g. offline alerts/reminders)
        final localOnly = localList.where((n) => !serverIds.contains(n.id)).toList();
        final merged = [...localOnly, ...serverList];
        merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        await _saveLocalNotifications(merged);

        var filtered = merged;
        if (status != null) {
          filtered = filtered.where((n) => n.status == status).toList();
        }
        final unreadCount = filtered.where((n) => !n.isRead).length;

        return {
          'notifications': filtered,
          'total': filtered.length,
          'unreadCount': unreadCount,
        };
      }
    } catch (_) {
      // Offline fallback: continue to read from persistent storage
    }

    // 2. Return local notifications
    var list = _getLocalNotifications();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (status != null) {
      list = list.where((n) => n.status == status).toList();
    }

    final unreadCount = list.where((n) => !n.isRead).length;

    return {
      'notifications': list,
      'total': list.length,
      'unreadCount': unreadCount,
    };
  }

  Future<void> markAsRead(String id) async {
    final list = _getLocalNotifications();
    final index = list.indexWhere((n) => n.id == id);
    if (index != -1) {
      final current = list[index];
      list[index] = NotificationModel(
        id: current.id,
        title: current.title,
        message: current.message,
        type: current.type,
        habitId: current.habitId,
        habitName: current.habitName,
        habitIcon: current.habitIcon,
        habitColor: current.habitColor,
        deliveredAt: current.deliveredAt,
        readAt: DateTime.now(),
        status: 'read',
        createdAt: current.createdAt,
      );
      await _saveLocalNotifications(list);
    }

    Future(() async {
      try {
        await apiClient.patch('${ApiConstants.notifications}/$id/read');
      } catch (_) {}
    });
  }

  Future<void> markAllAsRead() async {
    final list = _getLocalNotifications();
    final updated = list.map((n) {
      return NotificationModel(
        id: n.id,
        title: n.title,
        message: n.message,
        type: n.type,
        habitId: n.habitId,
        habitName: n.habitName,
        habitIcon: n.habitIcon,
        habitColor: n.habitColor,
        deliveredAt: n.deliveredAt,
        readAt: DateTime.now(),
        status: 'read',
        createdAt: n.createdAt,
      );
    }).toList();
    await _saveLocalNotifications(updated);

    Future(() async {
      try {
        await apiClient.patch(ApiConstants.notificationsReadAll);
      } catch (_) {}
    });
  }

  Future<void> deleteNotification(String id) async {
    final list = _getLocalNotifications();
    list.removeWhere((n) => n.id == id);
    await _saveLocalNotifications(list);

    Future(() async {
      try {
        await apiClient.delete('${ApiConstants.notifications}/$id');
      } catch (_) {}
    });
  }

  Future<void> clearAll() async {
    await _saveLocalNotifications([]);

    Future(() async {
      try {
        await apiClient.delete(ApiConstants.notifications);
      } catch (_) {}
    });
  }
}
