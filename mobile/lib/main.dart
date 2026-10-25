import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/notifications/local_notifications_service.dart';
import 'core/storage/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistent storage and UUID installation scoping
  await LocalStorage.init();

  // Initialize Android local notifications
  await LocalNotificationsService.init();

  runApp(
    const ProviderScope(
      child: HabitTrackerApp(),
    ),
  );
}
