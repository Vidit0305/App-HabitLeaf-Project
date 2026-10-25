import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/custom_card.dart';

class StreakSummaryCard extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const StreakSummaryCard({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Current Streak
        Expanded(
          child: CustomCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            borderRadius: 16,
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.streakGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$currentStreak ${currentStreak == 1 ? "day" : "days"}',
                        style: AppTypography.titleLarge.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Current Streak',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Longest Streak
        Expanded(
          child: CustomCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            borderRadius: 16,
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDarkElevated
                        : AppColors.softBlueBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.streakGold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$longestStreak ${longestStreak == 1 ? "day" : "days"}',
                        style: AppTypography.titleLarge.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Longest Streak',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
