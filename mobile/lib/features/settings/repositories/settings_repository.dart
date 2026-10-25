import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../models/settings_model.dart';

class SettingsRepository {
  final ApiClient apiClient;

  SettingsRepository({required this.apiClient});

  SettingsModel _getLocalSettings() {
    final cached = LocalStorage.getString(AppConstants.keyCachedSettings);
    if (cached == null || cached.trim().isEmpty) return SettingsModel();
    try {
      final decoded = jsonDecode(cached) as Map<String, dynamic>;
      return SettingsModel.fromJson(decoded);
    } catch (_) {
      return SettingsModel();
    }
  }

  Future<void> _saveLocalSettings(SettingsModel settings) async {
    await LocalStorage.setString(AppConstants.keyCachedSettings, jsonEncode(settings.toJson()));
  }

  Future<SettingsModel> fetchSettings() async {
    Future(() async {
      try {
        final res = await apiClient.get(ApiConstants.settings);
        if (res != null && res['data'] is Map) {
          final serverSettings = SettingsModel.fromJson(res['data'] as Map<String, dynamic>);
          await _saveLocalSettings(serverSettings);
        }
      } catch (_) {}
    });

    return _getLocalSettings();
  }

  Future<SettingsModel> updateSettings(Map<String, dynamic> data) async {
    final current = _getLocalSettings();
    final updated = current.copyWith(
      displayName: data['displayName']?.toString() ?? current.displayName,
      avatarReference: data['avatarReference']?.toString() ?? current.avatarReference,
      themeMode: data['themeMode']?.toString() ?? current.themeMode,
      timeFormat: data['timeFormat']?.toString() ?? current.timeFormat,
      firstDayOfWeek: data['firstDayOfWeek']?.toString() ?? current.firstDayOfWeek,
      defaultReminderEnabled: data['defaultReminderEnabled'] is bool
          ? data['defaultReminderEnabled'] as bool
          : current.defaultReminderEnabled,
      dailySummaryEnabled: data['dailySummaryEnabled'] is bool
          ? data['dailySummaryEnabled'] as bool
          : current.dailySummaryEnabled,
    );

    await _saveLocalSettings(updated);

    Future(() async {
      try {
        await apiClient.patch(ApiConstants.settings, data: data);
      } catch (_) {}
    });

    return updated;
  }

  Future<void> resetAllData() async {
    await LocalStorage.clearAll();

    Future(() async {
      try {
        await apiClient.post(ApiConstants.settingsReset);
      } catch (_) {}
    });
  }

  Future<Map<String, dynamic>> exportBackupJson() async {
    final habits = LocalStorage.getString(AppConstants.keyCachedHabits);
    final completions = LocalStorage.getString(AppConstants.keyCachedCompletions);
    final settings = LocalStorage.getString(AppConstants.keyCachedSettings);

    return {
      'appName': AppConstants.appName,
      'appVersion': AppConstants.appVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'installationId': LocalStorage.getInstallationId(),
      'habits': habits != null ? jsonDecode(habits) : [],
      'completions': completions != null ? jsonDecode(completions) : [],
      'settings': settings != null ? jsonDecode(settings) : {},
    };
  }

  Future<void> importBackupJson(Map<String, dynamic> backupData) async {
    if (backupData['habits'] is List) {
      await LocalStorage.setString(AppConstants.keyCachedHabits, jsonEncode(backupData['habits']));
    }
    if (backupData['completions'] is List) {
      await LocalStorage.setString(AppConstants.keyCachedCompletions, jsonEncode(backupData['completions']));
    }
    if (backupData['settings'] is Map) {
      await LocalStorage.setString(AppConstants.keyCachedSettings, jsonEncode(backupData['settings']));
    }

    Future(() async {
      try {
        await apiClient.post(ApiConstants.backupImport, data: backupData);
      } catch (_) {}
    });
  }
}
