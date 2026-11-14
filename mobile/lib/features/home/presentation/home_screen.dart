import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/haptic_feedback_helper.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../habits/controllers/habits_controller.dart';
import '../../habits/presentation/add_edit_habit_modal.dart';
import '../../habits/presentation/habit_detail_screen.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../statistics/controllers/statistics_controller.dart';
import 'widgets/daily_progress_card.dart';
import 'widgets/home_header.dart';
import 'widgets/streak_summary_card.dart';
import 'widgets/today_habit_card.dart';

class HomeScreen extends ConsumerWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsState = ref.watch(habitsProvider);
    final settingsState = ref.watch(settingsProvider);
    final summaryState = ref.watch(statisticsSummaryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayName = settingsState.maybeWhen(
      data: (s) => s.displayName,
      orElse: () => 'Alex',
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(habitsProvider.notifier).loadHabits();
            ref.invalidate(statisticsSummaryProvider);
          },
          color: AppColors.primaryRoyalBlue,
          child: habitsState.when(
            loading: () => _buildLoadingState(),
            error: (err, _) => _buildErrorState(context, ref, err.toString()),
            data: (allHabits) {
              // Filter habits scheduled for today
              final todayWeekDay = DateTime.now().weekday; // 1 = Mon ... 7 = Sun
              final todayHabits = allHabits.where((h) {
                if (h.isArchived) return false;
                if (h.frequency == 'every_day') return true;
                return h.selectedWeekdays.contains(todayWeekDay);
              }).toList();

              final completedToday = todayHabits.where((h) => h.isCompletedToday).length;
              final pendingToday = todayHabits.length - completedToday;
              final totalScheduled = todayHabits.length;

              final currentStreak = summaryState.maybeWhen(
                data: (s) => s.currentOverallStreak,
                orElse: () => 0,
              );
              final longestStreak = summaryState.maybeWhen(
                data: (s) => s.longestOverallStreak,
                orElse: () => 0,
              );

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header
                    HomeHeader(
                      displayName: displayName,
                      onAddHabit: () => _openAddHabitModal(context),
                    ),
                    const SizedBox(height: 20),

                    // 2. Daily Progress Card
                    DailyProgressCard(
                      completed: completedToday,
                      pending: pendingToday,
                      totalScheduled: totalScheduled,
                    ),
                    const SizedBox(height: 16),

                    // 3. Streak Summary
                    StreakSummaryCard(
                      currentStreak: currentStreak,
                      longestStreak: longestStreak,
                    ),
                    const SizedBox(height: 20),

                    const SizedBox(height: 24),

                    // 4. Today's Habits Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Today\'s Habits',
                              style: AppTypography.titleLarge.copyWith(
                                color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.surfaceDarkElevated
                                    : AppColors.softBlueBackground,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$totalScheduled',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.skyBlueLight : AppColors.primaryRoyalBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (allHabits.isNotEmpty)
                          TextButton(
                            onPressed: () => onNavigateTab?.call(1),
                            child: const Text('View All'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 7. Today's Habits List or Empty State
                    if (todayHabits.isEmpty)
                      EmptyState(
                        icon: Icons.track_changes_rounded,
                        title: allHabits.isEmpty
                            ? 'No Habits Yet'
                            : 'No Habits Scheduled Today',
                        message: allHabits.isEmpty
                            ? 'Start building positive daily routines. Create your first habit today!'
                            : 'You have no habits scheduled for today. Take a break or add a new one.',
                        buttonText: 'Create Your First Habit',
                        onAction: () => _openAddHabitModal(context),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: todayHabits.length,
                        itemBuilder: (context, index) {
                          final habit = todayHabits[index];
                          return TodayHabitCard(
                            habit: habit,
                            onToggle: () {
                              ref
                                  .read(habitsProvider.notifier)
                                  .toggleCompletion(habit.id);
                            },
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => HabitDetailScreen(habitId: habit.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _openAddHabitModal(BuildContext context) {
    HapticFeedbackHelper.light();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddEditHabitModal(),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonLoader(width: 140, height: 16),
          SizedBox(height: 8),
          SkeletonLoader(width: 220, height: 28),
          SizedBox(height: 24),
          SkeletonLoader(width: double.infinity, height: 130, borderRadius: 20),
          SizedBox(height: 16),
          SkeletonLoader(width: double.infinity, height: 70, borderRadius: 16),
          SizedBox(height: 24),
          SkeletonLoader(width: double.infinity, height: 80, borderRadius: 16),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 54, color: AppColors.primaryEmerald),
            const SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: AppTypography.titleLarge.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading local habits and offline data...',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedbackHelper.light();
                ref.read(habitsProvider.notifier).loadHabits();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh Habits'),
            ),
          ],
        ),
      ),
    );
  }
}
