import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/notifications/local_notifications_service.dart';
import '../../../../core/utils/haptic_feedback_helper.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../habits/controllers/habits_controller.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../statistics/controllers/statistics_controller.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsAsync = ref.watch(settingsProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryEmerald.withOpacity(0.2)
                    : AppColors.primaryGreenSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.settings_rounded,
                size: 20,
                color: AppColors.primaryGreenAccent,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: isDark ? Colors.white : AppColors.textDarkNavy,
                  ),
                ),
                Text(
                  'Preferences & Data',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreenAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.refresh_rounded, size: 48, color: AppColors.primaryEmerald),
              const SizedBox(height: 12),
              const Text('Tap to refresh settings', style: AppTypography.titleMedium),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedbackHelper.light();
                  ref.invalidate(settingsProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
        data: (settings) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Profile Section
                _buildSectionTitle('Personal Profile'),
                CustomCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 18,
                  backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryGreenAccent,
                        child: Text(
                          settings.displayName.isNotEmpty
                              ? settings.displayName[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              settings.displayName,
                              style: AppTypography.titleLarge.copyWith(
                                color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Personal Habit Tracker',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showEditNameDialog(context, ref, settings.displayName),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Appearance Section
                _buildSectionTitle('Appearance'),
                CustomCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 18,
                  backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme Mode',
                        style: AppTypography.titleMedium.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.light,
                              label: Text('Light'),
                              icon: Icon(Icons.light_mode_rounded, size: 16),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.dark,
                              label: Text('Dark'),
                              icon: Icon(Icons.dark_mode_rounded, size: 16),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.system,
                              label: Text('System'),
                              icon: Icon(Icons.brightness_auto_rounded, size: 16),
                            ),
                          ],
                          selected: {themeMode},
                          onSelectionChanged: (newSelection) {
                            HapticFeedbackHelper.selection();
                            final selected = newSelection.first;
                            final modeStr = selected == ThemeMode.light
                                ? 'light'
                                : (selected == ThemeMode.dark ? 'dark' : 'system');
                            ref.read(settingsProvider.notifier).updateThemeMode(modeStr);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Reminder Preferences
                _buildSectionTitle('Reminders & Notifications'),
                CustomCard(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 18,
                  backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Habit Reminders'),
                        subtitle: const Text('Send alerts at your scheduled reminder times'),
                        value: settings.defaultReminderEnabled,
                        activeColor: AppColors.primaryGreenAccent,
                        onChanged: (val) {
                          HapticFeedbackHelper.selection();
                          ref.read(settingsProvider.notifier).updatePreferences(
                            {'defaultReminderEnabled': val},
                          );
                        },
                      ),
                      const Divider(height: 12),
                      SwitchListTile(
                        title: const Text('Daily Summary'),
                        subtitle: const Text('Evening summary of today\'s progress'),
                        value: settings.dailySummaryEnabled,
                        activeColor: AppColors.primaryGreenAccent,
                        onChanged: (val) {
                          HapticFeedbackHelper.selection();
                          ref.read(settingsProvider.notifier).updatePreferences(
                            {'dailySummaryEnabled': val},
                          );
                        },
                      ),
                      const Divider(height: 12),
                      ListTile(
                        leading: const Icon(Icons.security_update_good_rounded, color: AppColors.primaryEmerald),
                        title: const Text('Notification Permissions'),
                        subtitle: const Text('Check Android notification and exact alarm settings'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () async {
                          HapticFeedbackHelper.light();
                          await LocalNotificationsService.requestPermissions();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Requested notification permissions from system.')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Data Management & Backup
                _buildSectionTitle('Data Management & Backups'),
                CustomCard(
                  padding: const EdgeInsets.all(8),
                  borderRadius: 18,
                  backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.download_rounded, color: AppColors.primaryGreenAccent),
                        title: const Text('Export JSON Backup'),
                        subtitle: const Text('Save your habits and completion history'),
                        onTap: () {
                          HapticFeedbackHelper.light();
                          _handleExportBackup(context, ref);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.upload_rounded, color: AppColors.primaryEmerald),
                        title: const Text('Import Backup File'),
                        subtitle: const Text('Restore data from a JSON backup file'),
                        onTap: () {
                          HapticFeedbackHelper.light();
                          _handleImportBackup(context, ref);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.delete_forever_rounded, color: AppColors.errorRed),
                        title: const Text(
                          'Clear All Data',
                          style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text('Wipe all habits, completions, and settings'),
                        onTap: () {
                          HapticFeedbackHelper.heavy();
                          _handleClearAllData(context, ref);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 5. About Section
                _buildSectionTitle('About'),
                CustomCard(
                  padding: const EdgeInsets.all(8),
                  borderRadius: 18,
                  backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline_rounded, color: AppColors.primaryGreenAccent),
                        title: const Text('About Habit Tracker'),
                        subtitle: const Text('Version 1.0.0 (Release Build)'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: const Text('Privacy Policy'),
                        subtitle: const Text('100% personal data. No accounts or tracking.'),
                        onTap: () {
                          HapticFeedbackHelper.light();
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Privacy & Data Isolation'),
                              content: const Text(
                                'Habit Tracker is strictly personal. Your habits, schedules, and analytics are scoped directly to your local installation. No email, password, or third-party advertising tracking is ever required.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTypography.titleSmall.copyWith(
          letterSpacing: 0.5,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGreenAccent,
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            hintText: 'Enter your preferred name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                HapticFeedbackHelper.selection();
                ref.read(settingsProvider.notifier).updatePreferences({'displayName': newName});
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExportBackup(BuildContext context, WidgetRef ref) async {
    final backup = await ref.read(settingsProvider.notifier).exportBackup();
    if (backup != null && context.mounted) {
      final jsonStr = jsonEncode(backup);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Backup JSON Export'),
          content: SingleChildScrollView(
            child: Text(
              jsonStr,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _handleImportBackup(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Backup JSON'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Paste valid Habit Tracker JSON backup payload here...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final decoded = jsonDecode(controller.text.trim());
                final success = await ref.read(settingsProvider.notifier).importBackup(decoded);
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  ref.invalidate(habitsProvider);
                  ref.invalidate(statisticsSummaryProvider);
                  ref.invalidate(trendsProvider);
                  ref.invalidate(notificationsProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Backup restored successfully!' : 'Failed to import backup.'),
                      backgroundColor: success ? AppColors.successGreenDark : AppColors.errorRed,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid JSON format: $e'), backgroundColor: AppColors.errorRed),
                  );
                }
              }
            },
            child: const Text('Restore Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleClearAllData(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Wipe All Data?',
      message:
          'This action is irreversible. All your habits, streaks, completions, and settings will be permanently erased.',
      confirmText: 'Erase Everything',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final success = await ref.read(settingsProvider.notifier).resetAllData();
      ref.invalidate(habitsProvider);
      ref.invalidate(statisticsSummaryProvider);
      ref.invalidate(trendsProvider);
      ref.invalidate(notificationsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'All data cleared successfully.' : 'Failed to clear data.'),
          ),
        );
      }
    }
  }
}
