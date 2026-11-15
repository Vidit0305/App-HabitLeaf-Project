import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/haptic_feedback_helper.dart';
import '../../../../core/utils/icon_helper.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../../habits/controllers/habits_controller.dart';
import '../../habits/models/habit_model.dart';
import '../controllers/statistics_controller.dart';
import '../models/statistics_model.dart';
import 'habit_monthly_history_screen.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryAsync = ref.watch(statisticsSummaryProvider);
    final trendsAsync = ref.watch(trendsProvider);
    final heatmapAsync = ref.watch(calendarHeatmapProvider);
    final habitsAsync = ref.watch(habitsProvider);
    final selectedTimeframe = ref.watch(selectedTimeframeProvider);
    final currentHeatmapDate = ref.watch(currentHeatmapDateProvider);

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
                Icons.insights_rounded,
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
                  'Progress & Analytics',
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
          ThemeToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryEmerald,
        onRefresh: () async {
          ref.invalidate(statisticsSummaryProvider);
          ref.invalidate(trendsProvider);
          ref.invalidate(calendarHeatmapProvider);
          ref.invalidate(habitsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Timeframe Filter Selector
              Row(
                children: ['weekly', 'monthly', 'yearly'].map((tf) {
                  final isSelected = selectedTimeframe == tf;
                  final label = tf[0].toUpperCase() + tf.substring(1);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) {
                        HapticFeedbackHelper.selection();
                        ref.read(selectedTimeframeProvider.notifier).state = tf;
                      },
                      selectedColor: AppColors.primaryRoyalBlue,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.textLight : AppColors.textDarkNavy),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 2. Summary Metrics Cards
              summaryAsync.when(
                loading: () => const SkeletonLoader(
                  width: double.infinity,
                  height: 140,
                  borderRadius: 18,
                ),
                error: (e, _) => Text(
                  'Error loading summary: $e',
                  style: TextStyle(
                    color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                  ),
                ),
                data: (summary) => _buildSummaryCards(summary, isDark),
              ),
              const SizedBox(height: 24),

              // 3. Trends Charts
              trendsAsync.when(
                loading: () => const SkeletonLoader(
                  width: double.infinity,
                  height: 240,
                  borderRadius: 20,
                ),
                error: (e, _) => Text(
                  'Error loading charts: $e',
                  style: TextStyle(
                    color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                  ),
                ),
                data: (trends) => _buildTrendCharts(context, trends, selectedTimeframe, isDark),
              ),
              const SizedBox(height: 28),

              // 4. Calendar Consistency Heatmap
              _buildHeatmapSection(context, ref, heatmapAsync, currentHeatmapDate, isDark),
              const SizedBox(height: 28),

              // 5. All Created Habits (Clickable to open HabitMonthlyHistoryScreen)
              _buildAllHabitsSection(context, habitsAsync, isDark),
              const SizedBox(height: 28),

              // 6. Habit Performance Comparison
              trendsAsync.maybeWhen(
                data: (trends) {
                  final list = trends['habitComparison'] as List<HabitComparisonItem>? ?? [];
                  if (list.isEmpty) return const SizedBox.shrink();
                  final allHabits = habitsAsync.valueOrNull ?? [];
                  return _buildHabitComparisonSection(context, list, allHabits, isDark);
                },
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(StatisticsSummary s, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricBox(
                label: 'Overall Success',
                value: '${s.overallCompletionRate}%',
                icon: Icons.pie_chart_rounded,
                color: AppColors.primaryRoyalBlue,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricBox(
                label: 'Today Done',
                value: '${s.completedToday} / ${s.totalScheduledToday}',
                icon: Icons.check_circle_rounded,
                color: AppColors.successGreen,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricBox(
                label: 'Total Completed',
                value: '${s.totalCompletions}',
                icon: Icons.verified_rounded,
                color: AppColors.skyBlue,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricBox(
                label: 'Current Streak',
                value: '${s.currentOverallStreak} d',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.streakOrange,
                isDark: isDark,
              ),
            ),
          ],
        ),
        if (s.mostConsistentHabit != null) ...[
          const SizedBox(height: 12),
          CustomCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderRadius: 16,
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.streakGold, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Most Consistent Habit',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        s.mostConsistentHabit!['name']?.toString() ?? '',
                        style: AppTypography.titleMedium.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successGreenLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${s.mostConsistentHabit!['rate'] ?? 0}% rate',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.successGreenDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetricBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.displayMedium.copyWith(
              fontSize: 22,
              color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCharts(
    BuildContext context,
    Map<String, dynamic> trends,
    String timeframe,
    bool isDark,
  ) {
    if (timeframe == 'weekly') {
      final last7Days = trends['last7Days'] as List<DayTrendItem>? ?? [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Completion (Last 7 Days)',
            style: AppTypography.titleLarge.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            borderRadius: 20,
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = last7Days[group.x.toInt()];
                        return BarTooltipItem(
                          '${item.dayLabel}\n${rod.toY.round()}% (${item.completed}/${item.scheduled})',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 25,
                        getTitlesWidget: (val, meta) => Text(
                          '${val.toInt()}%',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          final idx = val.toInt();
                          if (idx >= 0 && idx < last7Days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                last7Days[idx].dayLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (val) => FlLine(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: last7Days.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: item.percentage.toDouble(),
                          color: item.percentage >= 100
                              ? AppColors.successGreen
                              : AppColors.primaryRoyalBlue,
                          width: 18,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 100,
                            color: isDark ? AppColors.surfaceDarkElevated : AppColors.softBlueBackground,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Monthly/Yearly Line trend
      final weeklyTrends = trends['weeklyTrends'] as List<WeeklyTrendItem>? ?? [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consistency Trend Over Time',
            style: AppTypography.titleLarge.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            borderRadius: 20,
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 25,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 25,
                        getTitlesWidget: (v, _) => Text(
                          '${v.toInt()}%',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx >= 0 && idx < weeklyTrends.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                weeklyTrends[idx].weekLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: weeklyTrends.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.percentage.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: AppColors.primaryRoyalBlue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primaryRoyalBlue.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildHeatmapSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<CalendarDayItem>> heatmapAsync,
    DateTime currentMonthDate,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Consistency Heatmap',
              style: AppTypography.titleLarge.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
              ),
            ),
            // Month Navigation
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                  ),
                  onPressed: () {
                    ref.read(currentHeatmapDateProvider.notifier).state =
                        DateTime(currentMonthDate.year, currentMonthDate.month - 1, 1);
                  },
                ),
                Text(
                  DateFormatter.formatMonthYear(currentMonthDate),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                  ),
                  onPressed: () {
                    ref.read(currentHeatmapDateProvider.notifier).state =
                        DateTime(currentMonthDate.year, currentMonthDate.month + 1, 1);
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Heatmap Grid
        CustomCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 20,
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          child: Column(
            children: [
              // Day headers (M T W T F S S)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                    .map((d) => SizedBox(
                          width: 36,
                          child: Center(
                            child: Text(
                              d,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const Divider(height: 16),
              // Calendar Tiles
              heatmapAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text(
                  'Error loading heatmap: $e',
                  style: TextStyle(
                    color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                  ),
                ),
                data: (days) => _buildHeatmapGrid(context, days, isDark),
              ),
              const SizedBox(height: 14),
              // Intensity Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Unscheduled', isDark ? Colors.white10 : Colors.black12, isDark),
                  const SizedBox(width: 8),
                  _buildLegendItem('0%', isDark ? AppColors.surfaceDarkElevated : const Color(0xFFFEE2E2), isDark),
                  const SizedBox(width: 8),
                  _buildLegendItem('Partial', AppColors.streakOrange, isDark),
                  const SizedBox(width: 8),
                  _buildLegendItem('100%', AppColors.successGreen, isDark),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeatmapGrid(BuildContext context, List<CalendarDayItem> days, bool isDark) {
    if (days.isEmpty) return const SizedBox.shrink();

    // Calculate leading blanks based on dayOfWeek of day 1 (1 = Mon..7 = Sun)
    final firstDayOfWeek = days.first.dayOfWeek == 0 ? 7 : days.first.dayOfWeek;
    final leadingBlanks = firstDayOfWeek - 1;

    final tiles = <Widget>[];
    for (int i = 0; i < leadingBlanks; i++) {
      tiles.add(const SizedBox(width: 36, height: 36));
    }

    for (final dayItem in days) {
      Color tileColor;
      Color textColor = isDark ? Colors.white : AppColors.textDarkNavy;

      switch (dayItem.intensity) {
        case 'full':
          tileColor = AppColors.successGreen;
          textColor = Colors.white;
          break;
        case 'partial':
          tileColor = AppColors.streakOrange;
          textColor = Colors.white;
          break;
        case 'none':
          tileColor = isDark ? AppColors.surfaceDarkElevated : const Color(0xFFFEE2E2);
          textColor = AppColors.errorRed;
          break;
        default:
          tileColor = isDark ? Colors.white10 : const Color(0xFFF1F5F9);
          textColor = isDark ? Colors.white38 : AppColors.textMuted;
          break;
      }

      tiles.add(
        GestureDetector(
          onTap: () => _showDayDetailBottomSheet(context, dayItem),
          child: Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.5,
              ),
            ),
            child: Center(
              child: Text(
                '${dayItem.day}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.start,
      children: tiles,
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showDayDetailBottomSheet(BuildContext context, CalendarDayItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.dateKey,
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: 18,
                      color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.percentage >= 100
                          ? AppColors.successGreenLight
                          : AppColors.softBlueBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${item.completedCount} / ${item.scheduledCount} (${item.percentage}%)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: item.percentage >= 100
                            ? AppColors.successGreenDark
                            : AppColors.primaryRoyalBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              if (item.habits.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No habits were scheduled on this date.',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: item.habits.length,
                  itemBuilder: (context, idx) {
                    final h = item.habits[idx];
                    final isDone = h['isCompleted'] == true;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: isDone ? AppColors.successGreen : AppColors.textSecondary,
                      ),
                      title: Text(
                        h['name'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(
                        isDone ? 'Completed' : 'Missed / Incomplete',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDone ? AppColors.successGreenDark : AppColors.errorRed,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // 5. Dedicated All Created Habits Section
  Widget _buildAllHabitsSection(
    BuildContext context,
    AsyncValue<List<HabitModel>> habitsAsync,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Created Habits',
              style: AppTypography.titleLarge.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Tap for month history',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreenAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Select any habit to inspect its complete month-by-month calendar from inception.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        habitsAsync.when(
          loading: () => const SkeletonLoader(
            width: double.infinity,
            height: 90,
            borderRadius: 16,
          ),
          error: (e, _) => Text(
            'Error loading habits: $e',
            style: TextStyle(
              color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
            ),
          ),
          data: (habits) {
            final activeHabits = habits.where((h) => !h.isArchived).toList();
            if (activeHabits.isEmpty) {
              return CustomCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 16,
                backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                child: Center(
                  child: Text(
                    'No habits created yet. Create a habit to start tracking monthly history.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: activeHabits.map((habit) {
                final habitColor = IconHelper.parseColor(habit.color);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        HapticFeedbackHelper.light();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HabitMonthlyHistoryScreen(habit: habit),
                          ),
                        );
                      },
                      child: CustomCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        borderRadius: 16,
                        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: habitColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                IconHelper.getIcon(habit.icon),
                                color: habitColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
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
                                        'From ${DateFormatter.formatShortDate(habit.startDate)}',
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
                            if (habit.currentStreak > 0) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreenSoft.withOpacity(isDark ? 0.2 : 0.6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department_rounded,
                                      color: AppColors.primaryGreenAccent,
                                      size: 13,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${habit.currentStreak} d',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryGreenAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreenAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // 6. Habit Performance Comparison
  Widget _buildHabitComparisonSection(
    BuildContext context,
    List<HabitComparisonItem> list,
    List<HabitModel> allHabits,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Habit Performance Comparison',
              style: AppTypography.titleLarge.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CustomCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 20,
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          child: Column(
            children: list.map((item) {
              final color = IconHelper.parseColor(item.color);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    HapticFeedbackHelper.light();
                    final habit = allHabits.firstWhere(
                      (h) => h.id == item.habitId,
                      orElse: () => HabitModel(
                        id: item.habitId,
                        name: item.name,
                        color: item.color,
                        icon: item.icon,
                        startDate: DateTime.now().subtract(const Duration(days: 30)),
                      ),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HabitMonthlyHistoryScreen(habit: habit),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(IconHelper.getIcon(item.icon), color: color, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '${item.percentage}% (${item.completedCount}/${item.scheduledCount})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: item.percentage / 100.0,
                            backgroundColor: isDark ? AppColors.surfaceDarkElevated : AppColors.softBlueBackground,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
