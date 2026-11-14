import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/haptic_feedback_helper.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsAsync = ref.watch(settingsProvider);

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
                Icons.tune_rounded,
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
                  'Settings',
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
        actions: const [
          // Professional Dark/Light theme toggle button on top right
          ThemeToggleButton(),
        ],
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.refresh_rounded, size: 48, color: AppColors.primaryEmerald),
              const SizedBox(height: 12),
              Text(
                'Tap to refresh settings',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                ),
              ),
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal Profile Section
                _buildSectionTitle('Personal Profile'),
                CustomCard(
                  padding: const EdgeInsets.all(18),
                  borderRadius: 18,
                  backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryEmerald.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            settings.displayName.isNotEmpty
                                ? settings.displayName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              settings.displayName.isNotEmpty ? settings.displayName : 'Alex',
                              style: AppTypography.titleLarge.copyWith(
                                color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
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
                        icon: const Icon(Icons.edit_rounded, color: AppColors.primaryGreenAccent),
                        tooltip: 'Edit Name',
                        onPressed: () {
                          HapticFeedbackHelper.light();
                          _showEditNameDialog(context, ref, settings.displayName);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        title: Text(
          'Edit Display Name',
          style: TextStyle(
            color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(
            color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
          ),
          decoration: const InputDecoration(
            labelText: 'Your Name',
            hintText: 'Enter your preferred name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedbackHelper.light();
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
