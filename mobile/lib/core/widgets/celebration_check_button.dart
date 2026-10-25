import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../utils/haptic_feedback_helper.dart';
import '../utils/sound_helper.dart';

class CelebrationCheckButton extends StatefulWidget {
  final bool isCompleted;
  final VoidCallback onToggle;
  final double size;

  const CelebrationCheckButton({
    super.key,
    required this.isCompleted,
    required this.onToggle,
    this.size = 40.0,
  });

  @override
  State<CelebrationCheckButton> createState() => _CelebrationCheckButtonState();
}

class _CelebrationCheckButtonState extends State<CelebrationCheckButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _ringScaleAnimation;
  late Animation<double> _ringOpacityAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.75).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.75, end: 1.25).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.25, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
    ]).animate(_controller);

    _ringScaleAnimation = Tween<double>(begin: 0.6, end: 1.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _ringOpacityAnimation = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
      ),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.9, curve: Curves.easeOutQuad),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isCompleted) {
      // Trigger celebratory vibrations & peaceful chime
      HapticFeedbackHelper.success();
      SoundHelper.playPeacefulChime();
      _controller.forward(from: 0.0);
    } else {
      HapticFeedbackHelper.light();
    }
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDone = widget.isCompleted;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.size + 24,
        height: widget.size + 24,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double ringScale = _ringScaleAnimation.value;
            final double ringOpacity = _ringOpacityAnimation.value;
            final double particleProgress = _particleAnimation.value;

            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 1. Expanding Radiant Halo Ring
                if (_controller.isAnimating && ringOpacity > 0.01)
                  Transform.scale(
                    scale: ringScale,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryEmerald.withOpacity(ringOpacity),
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),

                // 2. Sparkling Celebration Micro-particles
                if (_controller.isAnimating && particleProgress > 0.05 && particleProgress < 0.95)
                  ...List.generate(8, (i) {
                    final angle = (i * 45) * (math.pi / 180);
                    final distance = (widget.size * 0.7) + (particleProgress * 22);
                    final x = math.cos(angle) * distance;
                    final y = math.sin(angle) * distance;
                    final particleSize = (1.0 - particleProgress) * 4.5;
                    final particleAlpha = (1.0 - particleProgress).clamp(0.0, 1.0);

                    return Transform.translate(
                      offset: Offset(x, y),
                      child: Container(
                        width: particleSize,
                        height: particleSize,
                        decoration: BoxDecoration(
                          color: (i % 2 == 0 ? AppColors.primaryEmerald : const Color(0xFF34D399))
                              .withOpacity(particleAlpha),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryEmerald.withOpacity(particleAlpha * 0.6),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                // 3. Main Bouncing Button Container
                Transform.scale(
                  scale: _controller.isAnimating ? _scaleAnimation.value : 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutBack,
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      gradient: isDone
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF10B981),
                                Color(0xFF059669),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isDone
                          ? null
                          : (isDark ? AppColors.surfaceDarkElevated : Colors.white),
                      borderRadius: BorderRadius.circular(widget.size * 0.32),
                      border: Border.all(
                        color: isDone
                            ? AppColors.primaryEmerald
                            : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        width: 1.6,
                      ),
                      boxShadow: isDone
                          ? [
                              BoxShadow(
                                color: AppColors.primaryEmerald.withOpacity(0.45),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: const Color(0xFF34D399).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: AnimatedScale(
                        scale: isDone ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.elasticOut,
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
