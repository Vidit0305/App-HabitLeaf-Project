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
import '../../../../core/widgets/theme_toggle_button.dart';
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
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _row1Categories = ['All', 'Health', 'Fitness', 'Productivity'];
  final List<String> _row2Categories = ['Mindfulness', 'Learning', 'Finance', 'Personal'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddHabitModal(BuildContext context) {
    HapticFeedbackHelper.light();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEditHabitModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habitsState = ref.watch(habitsProvider);

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
        actions: const [
          // Professional Dark/Light theme toggle button on top right
          ThemeToggleButton(),
        ],
      ),
      // No floating action button on bottom right as requested
      body: Column(
        children: [
          // 1. Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),

          // 2. All Categories arranged in 2 neat fixed rows (all 8 visible on screen, no scrolling)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Column(
              children: [
                // Row 1
                Row(
                  children: _row1Categories.map((cat) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _buildCategoryChip(cat, isDark),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 6),
                // Row 2
                Row(
                  children: _row2Categories.map((cat) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _buildCategoryChip(cat, isDark),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 3. Habit List View
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryEmerald,
              onRefresh: () async {
                await ref.read(habitsProvider.notifier).loadHabits();
              },
              child: habitsState.when(
                loading: () => _buildLoadingList(),
                error: (e, _) => _buildErrorRetry(ref),
                data: (habits) => _buildHabitsList(habits, isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isDark) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        HapticFeedbackHelper.selection();
        setState(() => _selectedCategory = category);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 7),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryEmerald
              : (isDark ? AppColors.surfaceDarkElevated : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryEmerald
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryEmerald.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          category,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textLight : AppColors.textDarkNavy),
          ),
        ),
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
    var filtered = habits.where((h) => !h.isArchived).toList();

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
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: EmptyState(
            icon: Icons.track_changes_rounded,
            title: _searchQuery.isNotEmpty ? 'No Habits Found' : 'No Habits Yet',
            message: _searchQuery.isNotEmpty
                ? 'No habits match your search criteria.'
                : 'Start tracking positive habits and build daily consistency.',
            buttonText: 'Create Habit',
            onAction: () => _openAddHabitModal(context),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 10),
          borderRadius: 16,
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
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
              // Streak indicator
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
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: SkeletonLoader(width: double.infinity, height: 72, borderRadius: 16),
      ),
    );
  }
}
