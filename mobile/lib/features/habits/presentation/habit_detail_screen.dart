import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/haptic_feedback_helper.dart';
import '../../../../core/utils/icon_helper.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../controllers/habits_controller.dart';
import '../models/habit_model.dart';
import 'add_edit_habit_modal.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  Map<String, dynamic>? _habitStats;
  HabitModel? _habit;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabitData();
  }

  Future<void> _loadHabitData() async {
    setState(() => _isLoading = true);
    try {
      final habitRepo = ref.read(habitsRepositoryProvider);
      final statsRepo = ref.read(statisticsRepositoryProvider);

      final results = await Future.wait([
        habitRepo.fetchHabitById(widget.habitId),
        statsRepo.fetchHabitStatistics(widget.habitId),
      ]);

      if (mounted) {
        setState(() {
          _habit = results[0] as HabitModel?;
          _habitStats = results[1] as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              SkeletonLoader(width: double.infinity, height: 120, borderRadius: 20),
              SizedBox(height: 16),
              SkeletonLoader(width: double.infinity, height: 80, borderRadius: 16),
            ],
          ),
        ),
      );
    }

    if (_habit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Habit Details')),
        body: Center(
          child: Text(
            'Habit not found or was removed.',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final habit = _habit!;
    final habitColor = IconHelper.parseColor(habit.color);
    final completionRate = (_habitStats?['completionRate'] as num?)?.toInt() ?? 0;
    final totalCompleted = (_habitStats?['totalCompleted'] as num?)?.toInt() ?? 0;
    final recentHistory = _habitStats?['recentHistory'] as List? ?? [];

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Habit',
            onPressed: () async {
              HapticFeedbackHelper.light();
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddEditHabitModal(habitToEdit: habit),
              );
              _loadHabitData();
            },
          ),
          IconButton(
            icon: Icon(habit.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
            tooltip: habit.isArchived ? 'Unarchive Habit' : 'Archive Habit',
            onPressed: () {
              HapticFeedbackHelper.light();
              _toggleArchive(habit);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed),
            tooltip: 'Delete Habit',
            onPressed: () {
              HapticFeedbackHelper.heavy();
              _confirmDelete(habit);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Card
            CustomCard(
              padding: const EdgeInsets.all(20),
              borderRadius: 20,
              backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: habitColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      IconHelper.getIcon(habit.icon),
                      color: habitColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: AppTypography.displayMedium.copyWith(
                            fontSize: 20,
                            color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: habitColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                habit.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: habitColor,
                                ),
                              ),
                            ),
                            if (habit.isArchived) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Archived',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Current Streak',
                    value: '${habit.currentStreak} d',
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.streakOrange,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Best Streak',
                    value: '${habit.longestStreak} d',
                    icon: Icons.emoji_events_rounded,
                    color: AppColors.streakGold,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Success Rate',
                    value: '$completionRate%',
                    icon: Icons.percent_rounded,
                    color: AppColors.successGreen,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Completions',
                    value: '$totalCompleted',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.primaryRoyalBlue,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Description & Schedule Details
            Text(
              'Details',
              style: AppTypography.titleLarge.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
              ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
              child: Column(
                children: [
                  _buildDetailRow(
                    label: 'Target',
                    value: habit.isMeasurable
                        ? '${habit.targetValue} ${habit.targetUnit} daily'
                        : 'Daily completion',
                    isDark: isDark,
                  ),
                  const Divider(height: 20),
                  _buildDetailRow(
                    label: 'Frequency',
                    value: habit.frequency == 'every_day'
                        ? 'Every day'
                        : 'Selected weekdays (${habit.selectedWeekdays.map(DateFormatter.weekdayName).join(", ")})',
                    isDark: isDark,
                  ),
                  const Divider(height: 20),
                  _buildDetailRow(
                    label: 'Reminder',
                    value: habit.reminderEnabled ? habit.reminderTime : 'Disabled',
                    isDark: isDark,
                  ),
                  if (habit.description.isNotEmpty) ...[
                    const Divider(height: 20),
                    _buildDetailRow(
                      label: 'Notes',
                      value: habit.description,
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Last 14 Days History Grid
            Text(
              'Recent History (Last 14 Days)',
              style: AppTypography.titleLarge.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
              ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
              child: recentHistory.isEmpty
                  ? Text(
                      'No history recorded yet.',
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: recentHistory.map((item) {
                        final isSched = item['isScheduled'] == true;
                        final isDone = item['isCompleted'] == true;
                        final dateKey = item['dateKey']?.toString() ?? '';
                        Color dotColor;
                        if (!isSched) {
                          dotColor = isDark ? Colors.white10 : Colors.black12;
                        } else if (isDone) {
                          dotColor = AppColors.successGreen;
                        } else {
                          dotColor = isDark ? AppColors.surfaceDarkElevated : const Color(0xFFFEE2E2);
                        }

                        return Tooltip(
                          message: '$dateKey: ${isDone ? "Completed" : (isSched ? "Missed" : "Unscheduled")}',
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: dotColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDone
                                    ? AppColors.successGreenDark
                                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                              ),
                            ),
                            child: isDone
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
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
                title,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.displayMedium.copyWith(
              fontSize: 20,
              color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Future<void> _toggleArchive(HabitModel habit) async {
    final newArchived = !habit.isArchived;
    await ref.read(habitsProvider.notifier).archiveHabit(habit.id, newArchived);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmDelete(HabitModel habit) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Habit Permanently?',
      message:
          'Are you sure you want to delete "${habit.name}"? This action is permanent and will remove all completion records for this habit.',
      confirmText: 'Delete Permanently',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await ref.read(habitsProvider.notifier).deleteHabit(habit.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
