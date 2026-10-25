import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../utils/haptic_feedback_helper.dart';
import '../../features/settings/controllers/settings_controller.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedbackHelper.selection();
            ref.read(appThemeModeProvider.notifier).toggleTheme();
            final nextMode = isDark ? 'light' : 'dark';
            ref.read(settingsProvider.notifier).updateThemeMode(nextMode);
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryEmerald.withOpacity(0.14)
                  : AppColors.primaryGreenUltraSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? AppColors.primaryEmerald.withOpacity(0.35)
                    : AppColors.primaryGreenAccent.withOpacity(0.25),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: anim,
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    key: ValueKey<bool>(isDark),
                    size: 19,
                    color: isDark ? const Color(0xFFFBBF24) : AppColors.primaryGreenAccent,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isDark ? 'Light' : 'Dark',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textDarkNavy,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
