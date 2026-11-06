import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sky_tracker/app/constants/app_colors.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/constants/app_strings.dart';
import 'package:sky_tracker/app/constants/app_text_styles.dart';
import 'package:sky_tracker/app/routes/app_routes.dart';
import 'package:sky_tracker/core/widgets/animated_widgets.dart';
import 'package:sky_tracker/core/widgets/common_widgets.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        title: const Text(AppStrings.notifications),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: SkyIconButton(
              icon: Icons.settings_outlined,
              onPressed: () => Get.toNamed(AppRoutes.settings),
              tooltip: AppStrings.settings,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -90,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.10),
                      theme.colorScheme.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeSlideIn(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusFull,
                        ),
                        border: Border.all(
                          color: AppColors.successGreen.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PulseDot(
                            color: AppColors.successGreen,
                            size: 5,
                            pulseScale: 2.4,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'ALL CAUGHT UP',
                            style: AppTextStyles.overline.copyWith(
                              color: AppColors.successGreen,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const EmptyStateWidget(
                    title: AppStrings.noNotifications,
                    subtitle: 'Flight status changes, gate updates and delays will appear here as soon as they happen.',
                    icon: Icons.notifications_none_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    child: OutlinedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.settings),
                      icon: const Icon(Icons.tune_rounded, size: 17),
                      label: const Text('Notification preferences'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 46),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
