import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/app_constants.dart';
import '../storage/local_storage.dart';

class LocalNotificationsService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Original notification channel with default Android notification sound
  static const String channelId = 'habit_reminders_channel';
  static const String channelName = 'Habit Reminders';
  static const String channelDescription =
      'Notifications for daily habit reminders and streak achievements';

  /// Callback to notify in-app listeners (e.g. Riverpod notifications notifier)
  static void Function(Map<String, dynamic> notificationJson)? onNotificationReceived;

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('ic_notification');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint('Notification clicked: ${details.payload}');
        },
      );

      // Create Android Notification Channel with default sound and maximum importance
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.max,
        );
        await androidImplementation.createNotificationChannel(channel);
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('LocalNotificationsService init error (platform may not support): $e');
    }
  }

  static Future<void> requestPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('Request permission error: $e');
    }
  }

  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? habitId,
    String? habitName,
    String? habitIcon,
    String? habitColor,
    String type = 'reminder',
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        icon: 'ic_notification',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        color: Color(0xFF10B981),
        showWhen: true,
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);
      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );

      // Record this notification persistently so it appears in the Notification screen
      await _recordNotificationLocally(
        id: id.toString(),
        title: title,
        message: body,
        habitId: habitId,
        habitName: habitName,
        habitIcon: habitIcon,
        habitColor: habitColor,
        type: type,
      );
    } catch (e) {
      debugPrint('Error showing instant notification: $e');
    }
  }

  /// Saves the notification to local persistent cache and notifies active listeners
  static Future<void> _recordNotificationLocally({
    required String id,
    required String title,
    required String message,
    String? habitId,
    String? habitName,
    String? habitIcon,
    String? habitColor,
    String type = 'reminder',
  }) async {
    try {
      final now = DateTime.now();
      final notifMap = {
        '_id': 'local_${now.millisecondsSinceEpoch}_$id',
        'type': type,
        'title': title,
        'message': message,
        'habitId': habitId,
        'habitName': habitName,
        'habitIcon': habitIcon,
        'habitColor': habitColor,
        'deliveredAt': now.toIso8601String(),
        'readAt': null,
        'status': 'delivered',
        'createdAt': now.toIso8601String(),
      };

      final cached = LocalStorage.getString(AppConstants.keyCachedNotifications);
      List<dynamic> list = [];
      if (cached != null && cached.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(cached);
          if (decoded is List) list = decoded;
        } catch (_) {}
      }

      list.insert(0, notifMap);
      await LocalStorage.setString(AppConstants.keyCachedNotifications, jsonEncode(list));

      // Notify controller if active
      onNotificationReceived?.call(notifMap);
    } catch (e) {
      debugPrint('Error recording notification locally: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  static Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }

  /// Derives stable integer ID from MongoDB habit ObjectId string
  static int generateNotificationId(String habitId) {
    int hash = 0;
    for (int i = 0; i < habitId.length; i++) {
      hash = (31 * hash + habitId.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash % 100000;
  }
}
