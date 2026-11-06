import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sky_tracker/app/constants/app_colors.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/constants/app_text_styles.dart';

/// Shared motion tokens. Keeping timings in one place makes the whole app
/// feel like it was choreographed instead of assembled.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 520);
  static const Duration stage = Duration(milliseconds: 700);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve exit = Curves.easeInCubic;
}

/// Fades and slides a widget into place once it is mounted.
///
/// Use the [delay] to stagger items in a list or sections of a page.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.slow,
    this.offset = const Offset(0, 0.08),
    this.curve = AppMotion.standard,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final Curve curve;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        final t = _animation.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(
              widget.offset.dx * 40 * (1 - t),
              widget.offset.dy * 40 * (1 - t),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// Adds tactile press feedback (scale) around any tappable child.
class AnimatedPressable extends StatefulWidget {
  const AnimatedPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.96,
    this.duration = AppMotion.fast,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final Duration duration;
  final bool enabled;

  @override
  State<AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<AnimatedPressable> {
  bool _pressed = false;

  bool get _interactive =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  void _setPressed(bool value) {
    if (!_interactive) return;
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _interactive ? widget.onTap : null,
      onLongPress: _interactive ? widget.onLongPress : null,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: widget.duration,
        curve: AppMotion.standard,
        child: widget.child,
      ),
    );
  }
}

/// The app's signature surface: gradient fill, hairline border, soft shadow
/// and an optional press animation + ripple.
class AppSurfaceCard extends StatefulWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin = EdgeInsets.zero,
    this.radius = AppSpacing.radiusLg,
    this.color,
    this.gradient,
    this.borderColor,
    this.glow = false,
    this.pressedScale = 0.985,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final bool glow;
  final double pressedScale;

  @override
  State<AppSurfaceCard> createState() => _AppSurfaceCardState();
}

class _AppSurfaceCardState extends State<AppSurfaceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(widget.radius);
    final borderColor =
        widget.borderColor ?? scheme.outlineVariant.withValues(alpha: 0.9);
    final gradient =
        widget.gradient ??
        (widget.color == null && isDark ? AppColors.cardGradient : null);
    final background = widget.color ?? theme.cardTheme.color ?? scheme.surface;

    final shadows = <BoxShadow>[
      if (widget.glow)
        BoxShadow(
          color: AppColors.accentPurple.withValues(alpha: isDark ? 0.18 : 0.10),
          blurRadius: 32,
          offset: const Offset(0, 14),
        ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.28)
            : const Color(0xFF1B1340).withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ];

    return AnimatedScale(
      scale: _pressed ? widget.pressedScale : 1,
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      child: Container(
        margin: widget.margin,
        decoration: BoxDecoration(
          color: gradient == null ? background : null,
          gradient: gradient,
          borderRadius: radius,
          border: Border.all(color: borderColor, width: 1),
          boxShadow: _pressed ? const [] : shadows,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: widget.onTap == null
                  ? null
                  : (_) => setState(() => _pressed = true),
              onTapUp: widget.onTap == null
                  ? null
                  : (_) => setState(() => _pressed = false),
              onTapCancel: widget.onTap == null
                  ? null
                  : () => setState(() => _pressed = false),
              splashColor: AppColors.accentPurple.withValues(alpha: 0.10),
              highlightColor: Colors.transparent,
              child: Padding(padding: widget.padding, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small glowing status dot with a repeating pulse.
class PulseDot extends StatefulWidget {
  const PulseDot({
    super.key,
    required this.color,
    this.size = 8,
    this.pulseScale = 2.4,
  });

  final Color color;
  final double size;
  final double pulseScale;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diameter = widget.size * widget.pulseScale;
    return SizedBox(
      width: diameter,
      height: diameter,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = Curves.easeOut.transform(_controller.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size + (diameter - widget.size) * t,
                height: widget.size + (diameter - widget.size) * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.28 * (1 - t)),
                ),
              ),
              child!,
            ],
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.6),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Counts up to [value] on first build.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    super.key,
    required this.value,
    this.style,
    this.decimals = 0,
    this.suffix = '',
    this.duration = const Duration(milliseconds: 900),
  });

  final num value;
  final TextStyle? style;
  final int decimals;
  final String suffix;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Text(
          '${animatedValue.toStringAsFixed(decimals)}$suffix',
          style: style,
        );
      },
    );
  }
}

/// A dashed flight path with a plane that continuously taxis across it.
class AnimatedFlightPath extends StatefulWidget {
  const AnimatedFlightPath({
    super.key,
    required this.color,
    this.height = 20,
    this.duration = const Duration(milliseconds: 2600),
    this.planeSize = 14,
  });

  final Color color;
  final double height;
  final Duration duration;
  final double planeSize;

  @override
  State<AnimatedFlightPath> createState() => _AnimatedFlightPathState();
}

class _AnimatedFlightPathState extends State<AnimatedFlightPath>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DashedLinePainter(
                color: widget.color.withValues(alpha: 0.45),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = Curves.easeInOutSine.transform(_controller.value);
              return Align(alignment: Alignment(-1 + 2 * t, 0), child: child);
            },
            child: Transform.rotate(
              angle: math.pi / 2,
              child: Icon(
                Icons.flight_rounded,
                size: widget.planeSize,
                color: widget.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final y = size.height / 2;
    for (double x = 0; x < size.width; x += 7) {
      canvas.drawCircle(Offset(x, y), 1.1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class SegmentOption<T> {
  const SegmentOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Segmented control with a pill that slides between options.
class SegmentedTabs<T> extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.height = 44,
    this.activeColor,
    this.duration = AppMotion.normal,
  });

  final List<SegmentOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;
  final double height;
  final Color? activeColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final active = activeColor ?? scheme.primary;
    final selectedIndex = options
        .indexWhere((o) => o.value == value)
        .clamp(0, options.length - 1);
    final segmentWidthFactor = 1 / options.length;

    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.55 : 1,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedAlign(
                alignment: Alignment(
                  options.length == 1
                      ? 0
                      : -1 + (2 * selectedIndex) / (options.length - 1),
                  0,
                ),
                duration: duration,
                curve: Curves.easeOutCubic,
                child: FractionallySizedBox(
                  widthFactor: segmentWidthFactor,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: active,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: active.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: options.map((option) {
                  final isSelected = option.value == value;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(option.value),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: duration,
                          style: AppTextStyles.label.copyWith(
                            color: isSelected
                                ? Colors.white
                                : scheme.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (option.icon != null) ...[
                                Icon(
                                  option.icon,
                                  size: 15,
                                  color: isSelected
                                      ? Colors.white
                                      : scheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Text(
                                  option.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Theme-aware shimmer placeholder.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = AppSpacing.radiusSm,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.elevatedSurface : const Color(0xFFE9EBF3),
      highlightColor: isDark ? AppColors.borderStrong : Colors.white,
      period: const Duration(milliseconds: 1400),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Compact circular loader with the brand plane in the middle.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.label, this.size = 56});

  final String? label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                  backgroundColor: theme.colorScheme.outlineVariant,
                ),
              ),
              Icon(
                Icons.flight_rounded,
                size: size * 0.38,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            label!,
            style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 0.4),
          ),
        ],
      ],
    );
  }
}

/// Rounded app-bar style icon button with press feedback and optional dot.
class SkyIconButton extends StatelessWidget {
  const SkyIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.showDot = false,
    this.dotColor = AppColors.accentMagenta,
    this.tooltip,
    this.size = 20,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool showDot;
  final Color dotColor;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final button = AnimatedPressable(
      onTap: onPressed,
      pressedScale: 0.9,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.6,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: size, color: theme.colorScheme.onSurface),
            if (showDot)
              Positioned(
                top: 10,
                right: 11,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

/// Section heading with an optional action on the right.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.only(bottom: AppSpacing.sm),
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                visualDensity: VisualDensity.compact,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(actionLabel!),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_forward_rounded, size: 14),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
