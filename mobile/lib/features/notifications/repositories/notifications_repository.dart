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

  Future<Map<String, dynamic>> fetchNotifications({String? status}) async {
    // Attempt background sync
    Future(() async {
      try {
        final query = <String, dynamic>{};
        if (status != null) query['status'] = status;
        final res = await apiClient.get(ApiConstants.notifications, queryParameters: query);
        if (res != null && res['data'] is Map) {
          final serverList = (res['data']['notifications'] as List? ?? [])
              .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
              .toList();
          if (serverList.isNotEmpty) {
            await _saveLocalNotifications(serverList);
          }
        }
      } catch (_) {}
    });

    var list = _getLocalNotifications();
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
