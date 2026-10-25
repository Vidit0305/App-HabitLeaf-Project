import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/notifications/local_notifications_service.dart';
import '../../../core/providers/app_providers.dart';
import '../models/notification_model.dart';
import '../repositories/notifications_repository.dart';

class NotificationsNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final NotificationsRepository repository;

  NotificationsNotifier({required this.repository})
      : super(const AsyncValue.loading()) {
    LocalNotificationsService.onNotificationReceived = _handleIncomingNotification;
    loadNotifications();
  }

  void _handleIncomingNotification(Map<String, dynamic> json) {
    try {
      final notif = NotificationModel.fromJson(json);
      state.whenData((current) {
        final list = List<NotificationModel>.from(
          current['notifications'] as List<NotificationModel>? ?? [],
        );
        list.removeWhere((n) => n.id == notif.id);
        list.insert(0, notif);
        final unread = (current['unreadCount'] as int? ?? 0) + 1;
        state = AsyncValue.data({
          'notifications': list,
          'total': list.length,
          'unreadCount': unread,
        });
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    if (LocalNotificationsService.onNotificationReceived == _handleIncomingNotification) {
      LocalNotificationsService.onNotificationReceived = null;
    }
    super.dispose();
  }

  Future<void> addNotification({
    required String title,
    required String message,
    String type = 'reminder',
    String? habitId,
    String? habitName,
    String? habitIcon,
    String? habitColor,
  }) async {
    try {
      final notif = await repository.addNotification(
        title: title,
        message: message,
        type: type,
        habitId: habitId,
        habitName: habitName,
        habitIcon: habitIcon,
        habitColor: habitColor,
      );
      state.whenData((current) {
        final list = List<NotificationModel>.from(
          current['notifications'] as List<NotificationModel>? ?? [],
        );
        list.removeWhere((n) => n.id == notif.id);
        list.insert(0, notif);
        final unread = (current['unreadCount'] as int? ?? 0) + 1;
        state = AsyncValue.data({
          'notifications': list,
          'total': list.length,
          'unreadCount': unread,
        });
      });
    } catch (_) {
      loadNotifications();
    }
  }

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final res = await repository.fetchNotifications();
      state = AsyncValue.data(res);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await repository.markAsRead(id);
      state.whenData((current) {
        final list = (current['notifications'] as List<NotificationModel>)
            .map((n) => n.id == id ? NotificationModel(
                  id: n.id,
                  type: n.type,
                  title: n.title,
                  message: n.message,
                  habitId: n.habitId,
                  habitName: n.habitName,
                  habitIcon: n.habitIcon,
                  habitColor: n.habitColor,
                  deliveredAt: n.deliveredAt,
                  readAt: DateTime.now(),
                  status: 'read',
                  createdAt: n.createdAt,
                ) : n)
            .toList();
        final unread = (current['unreadCount'] as int? ?? 1) - 1;
        state = AsyncValue.data({
          'notifications': list,
          'total': current['total'],
          'unreadCount': unread < 0 ? 0 : unread,
        });
      });
    } catch (_) {
      loadNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await repository.markAllAsRead();
      state.whenData((current) {
        final list = (current['notifications'] as List<NotificationModel>)
            .map((n) => NotificationModel(
                  id: n.id,
                  type: n.type,
                  title: n.title,
                  message: n.message,
                  habitId: n.habitId,
                  habitName: n.habitName,
                  habitIcon: n.habitIcon,
                  habitColor: n.habitColor,
                  deliveredAt: n.deliveredAt,
                  readAt: DateTime.now(),
                  status: 'read',
                  createdAt: n.createdAt,
                ))
            .toList();
        state = AsyncValue.data({
          'notifications': list,
          'total': current['total'],
          'unreadCount': 0,
        });
      });
    } catch (_) {
      loadNotifications();
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await repository.deleteNotification(id);
      state.whenData((current) {
        final list = (current['notifications'] as List<NotificationModel>)
            .where((n) => n.id != id)
            .toList();
        state = AsyncValue.data({
          'notifications': list,
          'total': (current['total'] as int? ?? 1) - 1,
          'unreadCount': current['unreadCount'],
        });
      });
    } catch (_) {
      loadNotifications();
    }
  }

  Future<void> clearAll() async {
    try {
      await repository.clearAll();
      state = const AsyncValue.data({
        'notifications': <NotificationModel>[],
        'total': 0,
        'unreadCount': 0,
      });
    } catch (_) {
      loadNotifications();
    }
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, AsyncValue<Map<String, dynamic>>>(
        (ref) {
  final repo = ref.watch(notificationsRepositoryProvider);
  return NotificationsNotifier(repository: repo);
});

// Single unread count provider for the bottom navigation badge
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificationsProvider);
  return state.maybeWhen(
    data: (data) => (data['unreadCount'] as int? ?? 0),
    orElse: () => 0,
  );
});
