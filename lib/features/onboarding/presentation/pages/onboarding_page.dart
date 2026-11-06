import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sky_tracker/app/constants/app_colors.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/constants/app_strings.dart';
import 'package:sky_tracker/app/constants/app_text_styles.dart';
import 'package:sky_tracker/app/routes/app_routes.dart';
import 'package:sky_tracker/core/services/theme_service.dart';
import 'package:sky_tracker/core/widgets/animated_widgets.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _orbit;
  int _currentPage = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      icon: Icons.flight_takeoff_rounded,
      accent: AppColors.accentPurple,
      tag: 'REAL-TIME',
      title: AppStrings.onboardingTitle1,
      subtitle: AppStrings.onboardingSubtitle1,
    ),
    _OnboardingSlide(
      icon: Icons.public_rounded,
      accent: AppColors.accentCyan,
      tag: 'WORLDWIDE',
      title: AppStrings.onboardingTitle2,
      subtitle: AppStrings.onboardingSubtitle2,
    ),
    _OnboardingSlide(
      icon: Icons.notifications_active_outlined,
      accent: AppColors.accentMagenta,
      tag: 'ALERTS',
      title: AppStrings.onboardingTitle3,
      subtitle: AppStrings.onboardingSubtitle3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _orbit.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    } else {
      _complete();
    }
  }

  void _back() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _complete() async {
    await ThemeService().completeOnboarding();
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.brightness == Brightness.dark
              ? AppColors.darkGradient
              : const LinearGradient(
                  colors: [Color(0xFFFBFAFF), Color(0xFFF1F2FB)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.sm,
                  AppSpacing.gutter,
                  0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.flight_rounded,
                        size: 19,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm + 2),
                    Text(
                      AppStrings.appName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _complete,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurfaceVariant,
                      ),
                      child: const Text(AppStrings.skip),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        var page = _currentPage.toDouble();
                        if (_pageController.hasClients &&
                            _pageController.position.haveDimensions) {
                          page = _pageController.page ?? page;
                        }
                        final delta = (index - page).clamp(-1.5, 1.5);
                        return Transform.translate(
                          offset: Offset(delta * 56, 0),
                          child: Opacity(
                            opacity: (1 - delta.abs() * 0.65).clamp(0.2, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: _SlideContent(
                        slide: _slides[index],
                        orbit: _orbit,
                      ),
                    );
                  },
                ),
              ),

              // Pagination dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final selected = _currentPage == i;
                  return GestureDetector(
                    onTap: () => _pageController.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeOutCubic,
                    ),
                    child: AnimatedContainer(
                      duration: AppMotion.normal,
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: selected ? 26 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusFull,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  0,
                  AppSpacing.gutter,
                  AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    AnimatedSize(
                      duration: AppMotion.normal,
                      curve: Curves.easeOutCubic,
                      child: _currentPage == 0
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: SizedBox(
                                width: AppSpacing.buttonHeight,
                                height: AppSpacing.buttonHeight,
                                child: OutlinedButton(
                                  onPressed: _back,
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusMd,
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_rounded,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    Expanded(
                      child: AnimatedPressable(
                        onTap: _next,
                        pressedScale: 0.97,
                        child: Container(
                          height: AppSpacing.buttonHeight,
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: AppMotion.normal,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.4),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: Row(
                                key: ValueKey(isLast),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isLast
                                        ? AppStrings.getStarted
                                        : AppStrings.next,
                                    style: AppTextStyles.buttonLarge,
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    isLast
                                        ? Icons.flight_takeoff_rounded
                                        : Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  const _SlideContent({required this.slide, required this.orbit});

  final _OnboardingSlide slide;
  final Animation<double> orbit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter + 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: orbit,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: orbit.value * 2 * math.pi,
                      child: child,
                    );
                  },
                  child: CustomPaint(
                    size: const Size(260, 260),
                    painter: _OrbitRingPainter(
                      color: slide.accent.withValues(alpha: 0.28),
                    ),
                  ),
                ),
                Container(
                  width: 178,
                  height: 178,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        slide.accent.withValues(alpha: 0.26),
                        slide.accent.withValues(alpha: 0.04),
                      ],
                      radius: 0.95,
                    ),
                    border: Border.all(
                      color: slide.accent.withValues(alpha: 0.22),
                    ),
                  ),
                ),
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.cardTheme.color,
                    border: Border.all(
                      color: slide.accent.withValues(alpha: 0.4),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: slide.accent.withValues(alpha: 0.28),
                        blurRadius: 34,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Icon(slide.icon, size: 46, color: slide.accent),
                ),
                Positioned(
                  top: 20,
                  right: 34,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                      border: Border.all(
                        color: slide.accent.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PulseDot(color: slide.accent, size: 5, pulseScale: 2.4),
                        const SizedBox(width: 5),
                        Text(
                          slide.tag,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: slide.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 18,
                  child: _FloatingChip(
                    icon: Icons.radar_rounded,
                    color: slide.accent,
                  ),
                ),
                Positioned(
                  bottom: 62,
                  right: 12,
                  child: _FloatingChip(
                    icon: Icons.speed_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(
              slide.subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingChip extends StatelessWidget {
  const _FloatingChip({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, size: 17, color: color),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  _OrbitRingPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    for (double angle = 0; angle < 2 * math.pi; angle += 0.33) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        0.16,
        false,
        paint,
      );
    }

    // Orbiting dots
    for (final angle in [-math.pi / 2, math.pi / 6, math.pi * 0.78]) {
      final dot = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawCircle(dot, 3.2, Paint()..color = color.withValues(alpha: 1));
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.accent,
    required this.tag,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color accent;
  final String tag;
  final String title;
  final String subtitle;
}
