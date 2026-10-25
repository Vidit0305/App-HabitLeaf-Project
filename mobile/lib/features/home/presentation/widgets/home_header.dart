import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/theme_toggle_button.dart';

class HomeHeader extends StatelessWidget {
  final String displayName;
  final VoidCallback? onAddHabit;

  const HomeHeader({
    super.key,
    required this.displayName,
    this.onAddHabit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final greeting = DateFormatter.getGreeting(displayName);
    final dateString = DateFormatter.formatFullDate(now);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryEmerald.withOpacity(0.18)
                          : AppColors.primaryGreenSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.eco_rounded,
                          size: 13,
                          color: AppColors.primaryGreenAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreenAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•  ${dateString.split(',')[0]}',
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                greeting,
                style: AppTypography.displayMedium.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Build consistency one day at a time',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const ThemeToggleButton(),
      ],
    );
  }
}
