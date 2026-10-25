import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/haptic_feedback_helper.dart';
import '../../../../core/utils/icon_helper.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../controllers/habits_controller.dart';
import '../models/habit_model.dart';
import 'add_edit_habit_modal.dart';
import 'habit_detail_screen.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  String _selectedStatus = 'Active'; // 'Active' or 'Archived'
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeHabitsState = ref.watch(habitsProvider);
    final archivedHabitsState = ref.watch(archivedHabitsProvider);

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
                Icons.track_changes_rounded,
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
                  'My Habits',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Habit',
            onPressed: () => _openAddHabitModal(context),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 75),
        child: FloatingActionButton.extended(
          onPressed: () => _openAddHabitModal(context),
          backgroundColor: AppColors.primaryGreenAccent,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Habit', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
      body: Column(
        children: [
          // 1. Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search habits...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          HapticFeedbackHelper.selection();
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // 2. Status & Category Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Active'),
                  selected: _selectedStatus == 'Active',
                  onSelected: (_) {
                    HapticFeedbackHelper.selection();
                    setState(() => _selectedStatus = 'Active');
                  },
                  selectedColor: AppColors.primaryGreenAccent,
                  labelStyle: TextStyle(
                    color: _selectedStatus == 'Active'
                        ? Colors.white
                        : (isDark ? AppColors.textLight : AppColors.textDarkNavy),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Archived'),
                  selected: _selectedStatus == 'Archived',
                  onSelected: (_) {
                    HapticFeedbackHelper.selection();
                    setState(() => _selectedStatus = 'Archived');
                  },
                  selectedColor: AppColors.primaryGreenAccent,
                  labelStyle: TextStyle(
                    color: _selectedStatus == 'Archived'
                        ? Colors.white
                        : (isDark ? AppColors.textLight : AppColors.textDarkNavy),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Category Chips Bar
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: ['All', ...AppConstants.categories].map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      HapticFeedbackHelper.selection();
                      setState(() => _selectedCategory = category);
                    },
                    selectedColor: isDark
                        ? AppColors.primaryEmerald.withOpacity(0.25)
                        : AppColors.primaryGreenSoft,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreenAccent)
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // 3. Habit List View
          Expanded(
            child: _selectedStatus == 'Active'
                ? activeHabitsState.when(
                    loading: () => _buildLoadingList(),
                    error: (e, _) => _buildErrorRetry(ref),
                    data: (habits) => _buildHabitsList(habits, isDark),
                  )
                : archivedHabitsState.when(
                    loading: () => _buildLoadingList(),
                    error: (e, _) => _buildErrorRetry(ref),
                    data: (habits) => _buildHabitsList(habits, isDark),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorRetry(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.refresh_rounded, size: 48, color: AppColors.primaryEmerald),
          const SizedBox(height: 12),
          const Text('Tap to refresh habits', style: AppTypography.titleMedium),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedbackHelper.light();
              ref.read(habitsProvider.notifier).loadHabits();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList(List<HabitModel> habits, bool isDark) {
    var filtered = habits;

    // Filter by Category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((h) => h.category == _selectedCategory).toList();
    }

    // Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((h) =>
              h.name.toLowerCase().contains(_searchQuery) ||
              h.description.toLowerCase().contains(_searchQuery))
          .toList();
    }

    if (filtered.isEmpty) {
      return EmptyState(
        icon: _selectedStatus == 'Active'
            ? Icons.track_changes_rounded
            : Icons.archive_outlined,
        title: _selectedStatus == 'Active'
            ? (_searchQuery.isNotEmpty ? 'No Habits Found' : 'No Active Habits')
            : 'No Archived Habits',
        message: _selectedStatus == 'Active'
            ? (_searchQuery.isNotEmpty
                ? 'No habits match your search criteria.'
                : 'Start tracking positive habits and build daily consistency.')
            : 'Archived habits will appear here.',
        buttonText: _selectedStatus == 'Active' ? 'Create New Habit' : null,
        onAction: _selectedStatus == 'Active'
            ? () => _openAddHabitModal(context)
            : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final habit = filtered[index];
        final habitColor = IconHelper.parseColor(habit.color);

        return CustomCard(
          onTap: () {
            HapticFeedbackHelper.light();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => HabitDetailScreen(habitId: habit.id),
              ),
            );
          },
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          borderRadius: 18,
          child: Row(
            children: [
              // Habit Icon
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: habitColor.withOpacity(isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  IconHelper.getIcon(habit.icon),
                  color: habitColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Name and Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                        fontWeight: FontWeight.w700,
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
                            color: habitColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            habit.category,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: habitColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          habit.isMeasurable
                              ? '${habit.targetValue.toInt()} ${habit.targetUnit} daily'
                              : (habit.frequency == 'every_day' ? 'Every day' : 'Scheduled days'),
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Streak / Reminder indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (habit.currentStreak > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreenSoft.withOpacity(isDark ? 0.2 : 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department_rounded,
                              color: AppColors.primaryGreenAccent, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            '${habit.currentStreak}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreenAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (habit.reminderEnabled) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.alarm_rounded,
                            size: 13,
                            color: isDark ? AppColors.textMuted : AppColors.textSecondary),
                        const SizedBox(width: 2),
                        Text(
                          habit.reminderTime,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? AppColors.textMuted : AppColors.borderLight,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (_, _) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: SkeletonLoader(width: double.infinity, height: 74, borderRadius: 18),
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
}
