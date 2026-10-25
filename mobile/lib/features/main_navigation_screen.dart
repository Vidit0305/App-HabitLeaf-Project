import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/haptic_feedback_helper.dart';
import 'home/presentation/home_screen.dart';
import 'habits/presentation/habits_screen.dart';
import 'notifications/presentation/notifications_screen.dart';
import 'notifications/controllers/notifications_controller.dart';
import 'statistics/presentation/statistics_screen.dart';
import 'settings/presentation/settings_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      HomeScreen(onNavigateTab: _onTabSelected),
      const HabitsScreen(),
      const NotificationsScreen(),
      const StatisticsScreen(),
      const SettingsScreen(),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: SizedBox(
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  index: 0,
                  label: 'Home',
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  isSelected: _currentIndex == 0,
                  isDark: isDark,
                ),
                _buildNavItem(
                  index: 1,
                  label: 'My Habits',
                  icon: Icons.check_circle_outline_rounded,
                  activeIcon: Icons.check_circle_rounded,
                  isSelected: _currentIndex == 1,
                  isDark: isDark,
                ),
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
                  icon: Icons.bar_chart_rounded,
                  activeIcon: Icons.insights_rounded,
                  isSelected: _currentIndex == 3,
                  isDark: isDark,
                ),
                _buildNavItem(
                  index: 4,
                  label: 'Settings',
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  isSelected: _currentIndex == 4,
                  isDark: isDark,
                ),
              ],
            ),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTabSelected(index),
          borderRadius: BorderRadius.circular(30),
          splashColor: activeColor.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 14 : 6,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? AppColors.primaryEmerald.withOpacity(0.18)
                          : AppColors.primaryGreenUltraSoft)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
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
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: isSelected ? -0.1 : 0,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
