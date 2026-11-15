import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/haptic_feedback_helper.dart';
import '../../../../core/utils/icon_helper.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../../habits/controllers/habits_controller.dart';
import '../../habits/models/habit_model.dart';

class HabitMonthlyHistoryScreen extends ConsumerStatefulWidget {
  final HabitModel habit;

  const HabitMonthlyHistoryScreen({
    super.key,
    required this.habit,
  });

  @override
  ConsumerState<HabitMonthlyHistoryScreen> createState() =>
      _HabitMonthlyHistoryScreenState();
}

class _HabitMonthlyHistoryScreenState
    extends ConsumerState<HabitMonthlyHistoryScreen> {
  bool _latestFirst = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habit = widget.habit;
    final habitColor = IconHelper.parseColor(habit.color);

    final completedDatesAsync =
        ref.watch(habitCompletedDatesProvider(habit.id));

    // Calculate all months from habit start date up to current month
    final now = DateTime.now();
    final start = DateTime(habit.startDate.year, habit.startDate.month, 1);
    final current = DateTime(now.year, now.month, 1);

    final List<DateTime> months = [];
    var cursor = start;
    while (!cursor.isAfter(current)) {
      months.add(cursor);
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }

    if (months.isEmpty) {
      months.add(current);
    }

    final displayMonths =
        _latestFirst ? months.reversed.toList() : months;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
            size: 20,
          ),
          onPressed: () {
            HapticFeedbackHelper.light();
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: habitColor.withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                IconHelper.getIcon(habit.icon),
                size: 18,
                color: habitColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Monthly History',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreenAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: completedDatesAsync.when(
        loading: () => _buildLoadingState(),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Error loading habit history: $e',
              style: TextStyle(
                color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
              ),
            ),
          ),
        ),
        data: (completedSet) {
          return RefreshIndicator(
            color: AppColors.primaryEmerald,
            onRefresh: () async {
              ref.invalidate(habitCompletedDatesProvider(habit.id));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Habit Overview Banner
                  _buildHabitBanner(habit, habitColor, completedSet.length, isDark),
                  const SizedBox(height: 16),

                  // 2. Color Legend (Completed: Green, Not Completed: White)
                  _buildColorLegend(isDark),
                  const SizedBox(height: 16),

                  // 3. Month Order Switcher
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Months (${displayMonths.length})',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedbackHelper.selection();
                          setState(() => _latestFirst = !_latestFirst);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDarkElevated
                                : AppColors.primaryGreenUltraSoft,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.swap_vert_rounded,
                                size: 14,
                                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreenAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _latestFirst ? 'Latest First' : 'Oldest First',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreenAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4. Months List with Complete Calendars
                  ...displayMonths.map((monthDate) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _buildMonthCalendarCard(
                        context,
                        monthDate: monthDate,
                        habit: habit,
                        completedSet: completedSet,
                        isDark: isDark,
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHabitBanner(
    HabitModel habit,
    Color habitColor,
    int totalCompleted,
    bool isDark,
  ) {
    final startStr = DateFormatter.formatFullDate(habit.startDate);

    return CustomCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: habitColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  IconHelper.getIcon(habit.icon),
                  color: habitColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: habitColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            habit.category,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: habitColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Started $startStr',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              _buildMiniMetric(
                label: 'Total Completed',
                value: '$totalCompleted days',
                icon: Icons.check_circle_rounded,
                color: AppColors.successGreen,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _buildMiniMetric(
                label: 'Current Streak',
                value: '${habit.currentStreak} d',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.streakOrange,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _buildMiniMetric(
                label: 'Best Streak',
                value: '${habit.longestStreak} d',
                icon: Icons.emoji_events_rounded,
                color: AppColors.streakGold,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDarkElevated : AppColors.bgLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorLegend(bool isDark) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 14,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.successGreenDark, width: 1.5),
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                'Completed (Green)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 20,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Not Completed (White)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendarCard(
    BuildContext context, {
    required DateTime monthDate,
    required HabitModel habit,
    required Set<String> completedSet,
    required bool isDark,
  }) {
    final year = monthDate.year;
    final month = monthDate.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday; // 1 = Mon, 7 = Sun
    final leadingBlanks = firstWeekday - 1;

    final now = DateTime.now();
    final todayZero = DateTime(now.year, now.month, now.day);
    final habitStartZero = DateTime(
      habit.startDate.year,
      habit.startDate.month,
      habit.startDate.day,
    );

    int monthCompletedCount = 0;
    int monthScheduledCount = 0;

    for (int d = 1; d <= daysInMonth; d++) {
      final dDate = DateTime(year, month, d);
      final dk = DateFormatter.toDateKey(dDate);

      // Only count days from start date up to today
      if (!dDate.isBefore(habitStartZero) && !dDate.isAfter(todayZero)) {
        final isSched = habit.frequency == 'every_day' ||
            habit.selectedWeekdays.contains(dDate.weekday);
        if (isSched) {
          monthScheduledCount++;
          if (completedSet.contains(dk)) {
            monthCompletedCount++;
          }
        }
      }
    }

    final monthPercentage = monthScheduledCount > 0
        ? ((monthCompletedCount / monthScheduledCount) * 100).round()
        : 0;

    return CustomCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    size: 18,
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreenAccent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormatter.formatMonthYear(monthDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: monthPercentage >= 100
                      ? AppColors.successGreenLight
                      : (isDark ? AppColors.surfaceDarkElevated : AppColors.primaryGreenUltraSoft),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: monthPercentage >= 100
                        ? AppColors.successGreen
                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                ),
                child: Text(
                  monthScheduledCount == 0
                      ? 'No scheduled days'
                      : '$monthCompletedCount / $monthScheduledCount ($monthPercentage%)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: monthPercentage >= 100
                        ? AppColors.successGreenDark
                        : (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreenAccent),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weekday Labels (M T W T F S S)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((dayLetter) {
              return Expanded(
                child: Center(
                  child: Text(
                    dayLetter,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Divider(height: 14),

          // 7-column Calendar Days Grid
          _buildMonthGrid(
            context: context,
            year: year,
            month: month,
            daysInMonth: daysInMonth,
            leadingBlanks: leadingBlanks,
            habitStartZero: habitStartZero,
            todayZero: todayZero,
            completedSet: completedSet,
            habit: habit,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid({
    required BuildContext context,
    required int year,
    required int month,
    required int daysInMonth,
    required int leadingBlanks,
    required DateTime habitStartZero,
    required DateTime todayZero,
    required Set<String> completedSet,
    required HabitModel habit,
    required bool isDark,
  }) {
    final totalSlots = leadingBlanks + daysInMonth;
    final totalRows = (totalSlots / 7).ceil();

    return Column(
      children: List.generate(totalRows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (colIndex) {
              final slotIndex = (rowIndex * 7) + colIndex;
              if (slotIndex < leadingBlanks || slotIndex >= totalSlots) {
                return const Expanded(child: SizedBox(height: 40));
              }

              final dayNum = slotIndex - leadingBlanks + 1;
              final dayDate = DateTime(year, month, dayNum);
              final dateKey = DateFormatter.toDateKey(dayDate);

              final isBeforeStart = dayDate.isBefore(habitStartZero);
              final isFuture = dayDate.isAfter(todayZero);
              final isCompleted = completedSet.contains(dateKey);

              Color bgColor;
              Color textColor;
              Border border;
              Widget? iconChild;

              if (isBeforeStart) {
                // Day prior to habit creation
                bgColor = isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFF1F5F9);
                textColor = isDark ? Colors.white24 : Colors.black26;
                border = Border.all(
                  color: isDark ? AppColors.borderDark.withOpacity(0.4) : const Color(0xFFE2E8F0),
                  width: 0.8,
                );
              } else if (isFuture) {
                // Future days (white with faint text)
                bgColor = Colors.white;
                textColor = const Color(0xFF94A3B8);
                border = Border.all(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  width: 1.2,
                );
              } else if (isCompleted) {
                // COMPLETED: GREEN with white text
                bgColor = AppColors.successGreen;
                textColor = Colors.white;
                border = Border.all(color: AppColors.successGreenDark, width: 1.5);
                iconChild = const Positioned(
                  bottom: 2,
                  right: 2,
                  child: Icon(Icons.check, size: 10, color: Colors.white),
                );
              } else {
                // NOT COMPLETED: WHITE with deep dark crisp text
                bgColor = Colors.white;
                textColor = const Color(0xFF0F172A);
                border = Border.all(
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                  width: 1.4,
                );
              }

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: GestureDetector(
                    onTap: () => _showDayDetail(
                      context,
                      dayDate: dayDate,
                      habit: habit,
                      isCompleted: isCompleted,
                      isBeforeStart: isBeforeStart,
                      isFuture: isFuture,
                      isDark: isDark,
                    ),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: border,
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: AppColors.successGreen.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '$dayNum',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCompleted ? FontWeight.w800 : FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          ?iconChild,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  void _showDayDetail(
    BuildContext context, {
    required DateTime dayDate,
    required HabitModel habit,
    required bool isCompleted,
    required bool isBeforeStart,
    required bool isFuture,
    required bool isDark,
  }) {
    HapticFeedbackHelper.light();
    final dateFormatted = DateFormatter.formatFullDate(dayDate);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String statusText;
        Color statusColor;
        IconData statusIcon;

        if (isBeforeStart) {
          statusText = 'Before Habit Created';
          statusColor = Colors.grey;
          statusIcon = Icons.history_rounded;
        } else if (isFuture) {
          statusText = 'Upcoming / Future Date';
          statusColor = AppColors.primaryRoyalBlue;
          statusIcon = Icons.hourglass_top_rounded;
        } else if (isCompleted) {
          statusText = 'Completed (Done)';
          statusColor = AppColors.successGreen;
          statusIcon = Icons.check_circle_rounded;
        } else {
          statusText = 'Not Completed (Missed)';
          statusColor = AppColors.errorRed;
          statusIcon = Icons.radio_button_unchecked_rounded;
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      dateFormatted,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: IconHelper.parseColor(habit.color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      IconHelper.getIcon(habit.icon),
                      color: IconHelper.parseColor(habit.color),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                          ),
                        ),
                        Text(
                          habit.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SkeletonLoader(width: double.infinity, height: 120, borderRadius: 18),
          SizedBox(height: 16),
          SkeletonLoader(width: double.infinity, height: 50, borderRadius: 14),
          SizedBox(height: 20),
          SkeletonLoader(width: double.infinity, height: 260, borderRadius: 18),
        ],
      ),
    );
  }
}
