import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/haptic_feedback_helper.dart';
import 'home/presentation/home_screen.dart';
import 'habits/presentation/habits_screen.dart';
import 'habits/presentation/add_edit_habit_modal.dart';
import 'notifications/presentation/notifications_screen.dart';
import 'notifications/controllers/notifications_controller.dart';
import 'statistics/presentation/statistics_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      HapticFeedbackHelper.selection();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _openAddHabitModal() {
    HapticFeedbackHelper.medium();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddEditHabitModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      HomeScreen(onNavigateTab: _onTabSelected),
      const HabitsScreen(),
      const NotificationsScreen(),
      const StatisticsScreen(),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 14),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // 1. Curved dock container
              Container(
                height: 64,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.45)
                          : AppColors.primaryGreenAccent.withOpacity(0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildNavItem(
                      index: 0,
                      label: 'Home',
                      icon: Icons.cottage_outlined,
                      activeIcon: Icons.cottage_rounded,
                      isSelected: _currentIndex == 0,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      index: 1,
                      label: 'My Habits',
                      icon: Icons.verified_outlined,
                      activeIcon: Icons.verified_rounded,
                      isSelected: _currentIndex == 1,
                      isDark: isDark,
                    ),
                    // Reserved spacing for the out-of-the-box floating + button
                    const SizedBox(width: 64),
                    _buildNavItem(
                      index: 2,
                      label: 'Notifications',
                      icon: Icons.notifications_none_rounded,
                      activeIcon: Icons.notifications_rounded,
                      isSelected: _currentIndex == 2,
                      isDark: isDark,
                      badgeCount: unreadCount,
                    ),
                    _buildNavItem(
                      index: 3,
                      label: 'Statistics',
                      icon: Icons.insights_outlined,
                      activeIcon: Icons.insights_rounded,
                      isSelected: _currentIndex == 3,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              // 2. Elevated Out-of-the-box + Button
              Positioned(
                bottom: 16,
                child: _buildCenterAddButton(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterAddButton(bool isDark) {
    return GestureDetector(
      onTap: _openAddHabitModal,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF047857)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.55),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required bool isSelected,
    required bool isDark,
    int badgeCount = 0,
  }) {
    final activeColor = isDark ? AppColors.primaryEmerald : AppColors.primaryGreenAccent;
    final inactiveColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 24,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: const BoxDecoration(
                        color: AppColors.errorRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 15,
                        minHeight: 15,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
                letterSpacing: isSelected ? -0.1 : 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
