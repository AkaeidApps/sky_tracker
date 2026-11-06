import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sky_tracker/app/constants/app_colors.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/constants/app_text_styles.dart';
import 'package:sky_tracker/app/routes/app_routes.dart';
import 'package:sky_tracker/core/services/theme_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _ambient;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _titleFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _progress;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0, 0.55, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _intro, curve: const Interval(0.05, 0.4)),
    );
    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _progress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.55, 1, curve: Curves.easeInOutCubic),
      ),
    );

    _intro.forward();
    _navigate();
  }

  void _navigate() {
    _navigationTimer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      final themeService = ThemeService();
      if (!themeService.isOnboardingCompleted()) {
        Get.offAllNamed(AppRoutes.onboarding);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _intro.dispose();
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.brightness == Brightness.dark
              ? AppColors.darkGradient
              : const LinearGradient(
                  colors: [Color(0xFFF7F5FF), Color(0xFFF0F1FA)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: Stack(
          children: [
            // Ambient glow
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ambient,
                builder: (context, _) {
                  final t = math.sin(_ambient.value * 2 * math.pi);
                  return IgnorePointer(
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment(0.1, -0.25 + 0.03 * t),
                          child: _GlowOrb(
                            color: theme.colorScheme.primary,
                            size: 340,
                            opacity: 0.22,
                          ),
                        ),
                        Align(
                          alignment: Alignment(-0.8, 0.55 - 0.04 * t),
                          child: _GlowOrb(
                            color: AppColors.accentCyan,
                            size: 220,
                            opacity: 0.10,
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0.85, 0.75),
                          child: _GlowOrb(
                            color: AppColors.accentMagenta,
                            size: 260,
                            opacity: 0.10,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: SizedBox(
                          width: 168,
                          height: 168,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _ambient,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _ambient.value * 2 * math.pi,
                                    child: child,
                                  );
                                },
                                child: CustomPaint(
                                  size: const Size(168, 168),
                                  painter: _OrbitPainter(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 104,
                                height: 104,
                                decoration: BoxDecoration(
                                  gradient: AppColors.brandGradient,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.45),
                                      blurRadius: 42,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 16),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.flight_rounded,
                                  size: 52,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FadeTransition(
                      opacity: _titleFade,
                      child: Text(
                        'SkyTrack',
                        style: AppTextStyles.display.copyWith(
                          fontSize: 40,
                          letterSpacing: -1.4,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    FadeTransition(
                      opacity: _taglineFade,
                      child: Text(
                        'LIVE FLIGHT TRACKER',
                        style: AppTextStyles.overline.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 3.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    FadeTransition(
                      opacity: _taglineFade,
                      child: AnimatedBuilder(
                        animation: _progress,
                        builder: (context, _) {
                          return SizedBox(
                            width: 152,
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusFull,
                                  ),
                                  child: LinearProgressIndicator(
                                    value: _progress.value,
                                    minHeight: 3,
                                    backgroundColor:
                                        theme.colorScheme.outlineVariant,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm + 2),
                                Text(
                                  'Preparing your flight deck',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: FadeTransition(
                opacity: _taglineFade,
                child: Text(
                  'v1.0.0',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
    required this.opacity,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Dashed orbit
    for (double angle = 0; angle < 2 * math.pi; angle += 0.24) {
      final start = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * math.cos(angle + 0.09),
        center.dy + radius * math.sin(angle + 0.09),
      );
      canvas.drawLine(start, end, paint);
    }

    // Small satellite dot
    final dotAngle = -math.pi / 3;
    final dot = Offset(
      center.dx + radius * math.cos(dotAngle),
      center.dy + radius * math.sin(dotAngle),
    );
    canvas.drawCircle(dot, 3.4, Paint()..color = color.withValues(alpha: 1));
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.color != color;
}
