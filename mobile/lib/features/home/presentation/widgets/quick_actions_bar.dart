import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

import '../../../../core/utils/haptic_feedback_helper.dart';

class QuickActionsBar extends StatelessWidget {
  final VoidCallback onAddHabit;
  final VoidCallback onViewAllHabits;
  final VoidCallback onOpenCalendar;
  final VoidCallback onReviewProgress;

  const QuickActionsBar({
    super.key,
    required this.onAddHabit,
    required this.onViewAllHabits,
    required this.onOpenCalendar,
    required this.onReviewProgress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildActionButton(
            context,
            icon: Icons.add_circle_outline_rounded,
            label: 'Add Habit',
            color: AppColors.primaryRoyalBlue,
            onTap: onAddHabit,
            isDark: isDark,
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            context,
            icon: Icons.list_alt_rounded,
            label: 'All Habits',
            color: AppColors.skyBlue,
            onTap: onViewAllHabits,
            isDark: isDark,
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            context,
            icon: Icons.calendar_month_rounded,
            label: 'Calendar',
            color: AppColors.streakGold,
            onTap: onOpenCalendar,
            isDark: isDark,
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            context,
            icon: Icons.insights_rounded,
            label: 'Analytics',
            color: AppColors.successGreen,
            onTap: onReviewProgress,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedbackHelper.selection();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
