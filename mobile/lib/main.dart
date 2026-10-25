import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'core/notifications/local_notifications_service.dart';
import 'core/storage/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using google-services.json configuration
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

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
