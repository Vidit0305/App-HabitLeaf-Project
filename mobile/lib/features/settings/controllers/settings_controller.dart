import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/storage/local_storage.dart';
import '../models/settings_model.dart';
import '../repositories/settings_repository.dart';
import '../../habits/controllers/habits_controller.dart';
import '../../statistics/controllers/statistics_controller.dart';
import '../../notifications/controllers/notifications_controller.dart';

// Theme Mode Provider
final appThemeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    loadTheme();
  }

  void loadTheme() {
    final saved = LocalStorage.getString(AppConstants.keyThemeMode);
    if (saved == 'light') {
      state = ThemeMode.light;
    } else if (saved == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> setTheme(String mode) async {
    await LocalStorage.setString(AppConstants.keyThemeMode, mode);
    if (mode == 'light') {
      state = ThemeMode.light;
    } else if (mode == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }
}

class SettingsNotifier extends StateNotifier<AsyncValue<SettingsModel>> {
  final SettingsRepository repository;
  final Ref ref;

  SettingsNotifier({required this.repository, required this.ref})
      : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final s = await repository.fetchSettings();
      state = AsyncValue.data(s);
      ref.read(appThemeModeProvider.notifier).setTheme(s.themeMode);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> updateProfile({required String displayName, String? avatarReference}) async {
    try {
      final updateData = {'displayName': displayName};
      if (avatarReference != null) updateData['avatarReference'] = avatarReference;
      final updated = await repository.updateSettings(updateData);
      state = AsyncValue.data(updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateThemeMode(String mode) async {
    try {
      await ref.read(appThemeModeProvider.notifier).setTheme(mode);
      final updated = await repository.updateSettings({'themeMode': mode});
      state = AsyncValue.data(updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updatePreferences(Map<String, dynamic> prefs) async {
    try {
      final updated = await repository.updateSettings(prefs);
      state = AsyncValue.data(updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> resetAllData() async {
    try {
      await repository.resetAllData();
      await LocalStorage.clearAll();
      await loadSettings();
      ref.read(habitsProvider.notifier).loadHabits();
      ref.invalidate(statisticsSummaryProvider);
      ref.invalidate(trendsProvider);
      ref.read(notificationsProvider.notifier).loadNotifications();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> exportBackup() async {
    try {
      return await repository.exportBackupJson();
    } catch (_) {
      return null;
    }
  }

  Future<bool> importBackup(Map<String, dynamic> backupData) async {
    try {
      await repository.importBackupJson(backupData);
      await loadSettings();
      ref.read(habitsProvider.notifier).loadHabits();
      ref.invalidate(statisticsSummaryProvider);
      ref.invalidate(trendsProvider);
      ref.read(notificationsProvider.notifier).loadNotifications();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<SettingsModel>>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository: repo, ref: ref);
});
