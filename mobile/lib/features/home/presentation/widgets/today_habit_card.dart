import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/haptic_feedback_helper.dart';
import '../../../../core/utils/icon_helper.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../habits/models/habit_model.dart';

class TodayHabitCard extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onToggle;
  final Function(double)? onUpdateMeasurable;
  final VoidCallback onTap;

  const TodayHabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    this.onUpdateMeasurable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habitColor = IconHelper.parseColor(habit.color);
    final isDone = habit.isCompletedToday;

    return CustomCard(
      onTap: () {
        HapticFeedbackHelper.light();
        onTap();
      },
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: 18,
      backgroundColor: isDark
          ? (isDone ? AppColors.surfaceDark.withOpacity(0.6) : AppColors.surfaceDark)
          : (isDone ? const Color(0xFFF6FAF7) : Colors.white),
      child: Column(
        children: [
          Row(
            children: [
              // Habit Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.successGreenLight.withOpacity(isDark ? 0.2 : 0.6)
                      : habitColor.withOpacity(isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isDone
                      ? Icons.check_circle_rounded
                      : IconHelper.getIcon(habit.icon),
                  color: isDone ? AppColors.successGreen : habitColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Habit Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            habit.name,
                            style: AppTypography.titleMedium.copyWith(
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: isDark
                                  ? (isDone ? AppColors.textMuted : AppColors.textLight)
                                  : (isDone ? AppColors.textMuted : AppColors.textDarkNavy),
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (habit.currentStreak > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreenSoft.withOpacity(isDark ? 0.2 : 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: AppColors.primaryGreenAccent,
                                  size: 13,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${habit.currentStreak}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryGreenAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        // Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDarkElevated
                                : AppColors.primaryGreenUltraSoft,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            habit.category,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreenAccent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Target / Schedule
                        Text(
                          habit.isMeasurable
                              ? '${habit.todayCompletedValue.toStringAsFixed(habit.todayCompletedValue.truncateToDouble() == habit.todayCompletedValue ? 0 : 1)} / ${habit.targetValue.toStringAsFixed(habit.targetValue.truncateToDouble() == habit.targetValue ? 0 : 1)} ${habit.targetUnit}'
                              : (habit.description.isNotEmpty ? habit.description : 'Daily habit'),
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Completion Checkbox / Toggle
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (!isDone) {
                      HapticFeedbackHelper.success();
                    } else {
                      HapticFeedbackHelper.light();
                    }
                    onToggle();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.primaryEmerald
                          : (isDark ? AppColors.surfaceDarkElevated : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDone
                            ? AppColors.primaryEmerald
                            : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        width: 1.5,
                      ),
                      boxShadow: isDone
                          ? [
                              BoxShadow(
                                color: AppColors.primaryEmerald.withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: isDone
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 22,
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
          // Measurable Habit Progress Bar and Quick Increment
          if (habit.isMeasurable) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (habit.todayCompletedValue / habit.targetValue).clamp(0.0, 1.0),
                backgroundColor: isDark ? AppColors.surfaceDarkElevated : AppColors.primaryGreenUltraSoft,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDone ? AppColors.primaryEmerald : habitColor,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
