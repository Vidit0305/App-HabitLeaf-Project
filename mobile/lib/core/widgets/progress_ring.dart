import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class ProgressRing extends StatelessWidget {
  final double percentage; // 0 to 100
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? trackColor;
  final bool showPercentageText;
  final TextStyle? textStyle;

  const ProgressRing({
    super.key,
    required this.percentage,
    this.size = 80,
    this.strokeWidth = 8,
    this.progressColor,
    this.trackColor,
    this.showPercentageText = true,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = (percentage.clamp(0, 100)) / 100.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveProgressColor = progressColor ??
        (percentage >= 100 ? AppColors.successGreen : AppColors.primaryRoyalBlue);
    final effectiveTrackColor = trackColor ??
        (isDark ? AppColors.surfaceDarkElevated : AppColors.softBlueBackground);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              color: effectiveTrackColor,
            ),
          ),
          // Animated progress ring
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: clamped),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: val,
                  strokeWidth: strokeWidth,
                  strokeCap: StrokeCap.round,
                  color: effectiveProgressColor,
                ),
              );
            },
          ),
          // Center Text
          if (showPercentageText)
            Text(
              '${percentage.round()}%',
              style: textStyle ??
                  TextStyle(
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textLight : AppColors.textDarkNavy,
                  ),
            ),
        ],
      ),
    );
  }
}
