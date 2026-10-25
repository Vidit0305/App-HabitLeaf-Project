import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/progress_ring.dart';

class DailyProgressCard extends StatelessWidget {
  final int completed;
  final int pending;
  final int totalScheduled;

  const DailyProgressCard({
    super.key,
    required this.completed,
    required this.pending,
    required this.totalScheduled,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = totalScheduled > 0
        ? ((completed / totalScheduled) * 100).clamp(0, 100).toDouble()
        : 0.0;

    return CustomCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      child: Row(
        children: [
          // Circular Progress Ring
          ProgressRing(
            percentage: percentage,
            size: 88,
            strokeWidth: 9,
            progressColor: percentage >= 100
                ? AppColors.successGreen
                : AppColors.primaryRoyalBlue,
          ),
          const SizedBox(width: 20),
          // Progress Stats Breakdown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Progress',
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                      ),
                    ),
                    if (percentage >= 100 && totalScheduled > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.successGreenLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Done! 🎉',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.successGreenDark,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  totalScheduled == 0
                      ? 'No habits scheduled today'
                      : '$completed of $totalScheduled habits completed',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                // Completed & Pending chips
                Row(
                  children: [
                    _buildStatBadge(
                      icon: Icons.check_circle_rounded,
                      color: AppColors.successGreen,
                      label: '$completed Completed',
                      isDark: isDark,
                    ),
                    const SizedBox(width: 10),
                    _buildStatBadge(
                      icon: Icons.hourglass_top_rounded,
                      color: AppColors.streakOrange,
                      label: '$pending Pending',
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required Color color,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
