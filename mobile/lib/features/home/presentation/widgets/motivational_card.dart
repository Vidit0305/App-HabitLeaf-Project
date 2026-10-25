import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_card.dart';

class MotivationalCard extends StatelessWidget {
  final int completedToday;
  final int totalScheduled;

  const MotivationalCard({
    super.key,
    required this.completedToday,
    required this.totalScheduled,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Pick contextual message
    String quote;
    IconData icon;
    if (totalScheduled > 0 && completedToday == totalScheduled) {
      quote = 'Incredible job! All habits completed today. Keep the momentum going tomorrow!';
      icon = Icons.stars_rounded;
    } else if (completedToday > 0) {
      quote = 'Great progress! You are actively forging the identity of who you want to become.';
      icon = Icons.bolt_rounded;
    } else {
      final index = DateTime.now().day % AppConstants.motivationalQuotes.length;
      quote = AppConstants.motivationalQuotes[index];
      icon = Icons.format_quote_rounded;
    }

    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 16,
      backgroundColor: isDark
          ? AppColors.primaryRoyalBlue.withOpacity(0.12)
          : AppColors.softBlueBackground,
      border: Border.all(
        color: isDark
            ? AppColors.primaryRoyalBlue.withOpacity(0.3)
            : const Color(0xFFDBEAFE),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryRoyalBlue.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDark ? AppColors.skyBlueLight : AppColors.primaryRoyalBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              quote,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
