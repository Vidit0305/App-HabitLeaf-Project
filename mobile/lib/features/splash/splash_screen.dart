import 'package:flutter/material.dart';
import '../main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.9, curve: Curves.easeInOutCubic),
      ),
    );

    _controller.forward();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, __, ___) => const MainNavigationScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Top-Left Flowing Organic Wave
          Positioned(
            top: 0,
            left: 0,
            child: CustomPaint(
              size: const Size(220, 180),
              painter: _TopLeftWavePainter(),
            ),
          ),

          // 2. Bottom-Right Flowing Organic Wave
          Positioned(
            bottom: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(220, 180),
              painter: _BottomRightWavePainter(),
            ),
          ),

          // 3. Central Brand & Content
          SafeArea(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // Brand Leaf Emblem
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withOpacity(0.35),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(36),
                            child: Image.asset(
                              'assets/images/leaf_logo.png',
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // App Name in bold modern uppercase
                    Opacity(
                      opacity: _fadeAnimation.value,
                      child: const Text(
                        'HABITLEAF',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Slogan in emerald green
                    Opacity(
                      opacity: _fadeAnimation.value,
                      child: const Text(
                        'BUILD BETTER HABITS EVERY DAY.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.8,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Minimal animated progress bar
                    SizedBox(
                      width: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _progressAnimation.value,
                          minHeight: 5,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Loading...
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Bottom: Made by Vidit Sharma
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Made by Vidit Sharma',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: const Color(0xFF0F172A).withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Wave Painters for Top-Left and Bottom-Right corner accents
class _TopLeftWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF34D399), Color(0xFF10B981)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path1 = Path();
    path1.moveTo(0, 0);
    path1.lineTo(size.width, 0);
    path1.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.3,
      size.width * 0.2,
      size.height * 0.85,
    );
    path1.quadraticBezierTo(
      size.width * 0.1,
      size.height * 1.0,
      0,
      size.height,
    );
    path1.close();
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x806EE7B7), Color(0x2010B981)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width * 1.2, size.height * 1.2));

    final path2 = Path();
    path2.moveTo(0, 0);
    path2.lineTo(size.width * 0.7, 0);
    path2.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.4,
      0,
      size.height * 0.65,
    );
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomRightWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF059669), Color(0xFF10B981)],
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.7,
      size.width * 0.8,
      size.height * 0.15,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      0,
      size.width,
      0,
    );
    path.close();
    canvas.drawPath(path, paint);

    final paintLight = Paint()
      ..color = const Color(0x4034D399);

    final pathLight = Path();
    pathLight.moveTo(size.width, size.height);
    pathLight.lineTo(size.width * 0.3, size.height);
    pathLight.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.6,
      size.width,
      size.height * 0.35,
    );
    pathLight.close();
    canvas.drawPath(pathLight, paintLight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
