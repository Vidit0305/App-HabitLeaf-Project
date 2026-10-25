import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../../features/habits/repositories/habits_repository.dart';
import '../../features/notifications/repositories/notifications_repository.dart';
import '../../features/statistics/repositories/statistics_repository.dart';
import '../../features/settings/repositories/settings_repository.dart';

// Single ApiClient Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Repositories
final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return HabitsRepository(apiClient: client);
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return NotificationsRepository(apiClient: client);
});

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return StatisticsRepository(apiClient: client);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return SettingsRepository(apiClient: client);
});
