import 'package:flutter/material.dart';
import 'package:sky_tracker/app/constants/app_colors.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/constants/app_text_styles.dart';
import 'package:sky_tracker/core/widgets/animated_widgets.dart';

/// Animated empty state with a floating, gradient-backed icon.
class EmptyStateWidget extends StatefulWidget {
  const EmptyStateWidget({
    super.key,
    this.title = 'No Data',
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: FadeSlideIn(
        offset: const Offset(0, 0.12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = Curves.easeInOutSine.transform(_controller.value);
                  return Transform.translate(
                    offset: Offset(0, -6 * t),
                    child: child,
                  );
                },
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.22),
                        theme.colorScheme.secondary.withValues(alpha: 0.10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 38,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 17),
                textAlign: TextAlign.center,
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: AppSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(
                    widget.subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (widget.action != null) ...[
                const SizedBox(height: AppSpacing.lg),
                widget.action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated error state with a retry action.
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    this.message = 'Something went wrong',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: FadeSlideIn(
        offset: const Offset(0, 0.12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.errorRed.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.errorRed.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 34,
                  color: AppColors.errorRed,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Something went off course',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try again'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(150, 46),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer placeholder block (kept for API compatibility).
class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({
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
    return ShimmerBox(width: width, height: height, radius: radius);
  }
}

/// Skeleton used while flight lists load.
class FlightListSkeleton extends StatelessWidget {
  const FlightListSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.gutter,
        AppSpacing.lg,
      ),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ShimmerBox(width: 70, height: 20, radius: 6),
                  const Spacer(),
                  const ShimmerBox(width: 56, height: 20, radius: 6),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: const [
                  ShimmerBox(width: 52, height: 30),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: ShimmerBox(height: 8),
                    ),
                  ),
                  ShimmerBox(width: 52, height: 30),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const ShimmerBox(width: 130, height: 12),
            ],
          ),
        );
      },
    );
  }
}

/// Dimmed overlay with a centered loader; animates in and out.
class PageLoadingOverlay extends StatelessWidget {
  const PageLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        IgnorePointer(
          ignoring: !isLoading,
          child: AnimatedSwitcher(
            duration: AppMotion.normal,
            child: isLoading
                ? Container(
                    key: const ValueKey('overlay'),
                    color: Colors.black.withValues(alpha: 0.45),
                    child: const Center(child: AppLoader()),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

/// Small pill used for metadata (gate, terminal, counts…).
class MetaChip extends StatelessWidget {
  const MetaChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.dense = false,
  });

  final String label;
  final IconData? icon;
  final Color? color;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = color ?? theme.colorScheme.primary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSpacing.sm : AppSpacing.sm + 2,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: tint.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 11 : 13, color: tint),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: tint,
              fontWeight: FontWeight.w600,
              fontSize: dense ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }
}
