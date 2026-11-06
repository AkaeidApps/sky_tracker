import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sky_tracker/app/constants/app_colors.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/constants/app_strings.dart';
import 'package:sky_tracker/app/constants/app_text_styles.dart';
import 'package:sky_tracker/app/routes/app_routes.dart';
import 'package:sky_tracker/core/services/favorites_service.dart';
import 'package:sky_tracker/core/services/theme_service.dart';
import 'package:sky_tracker/core/widgets/animated_widgets.dart';
import 'package:sky_tracker/core/widgets/common_widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FavoritesService _favoritesService = Get.find<FavoritesService>();
  final ThemeService _themeService = ThemeService();

  void _showPrivacy() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text(
          'SkyTrack stores your favorites, recent searches and theme preference '
          'only on this device. Flight data is requested from a public flight '
          'tracking API and is never linked to a personal account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.flight_rounded, color: AppColors.accentPurple),
            SizedBox(width: 10),
            Text('SkyTrack'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live flight tracker for the curious traveller.'),
            SizedBox(height: 12),
            Text('Version 1.0.0', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You are browsing as a guest. Logging out clears your saved flights '
          'and recent searches from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              minimumSize: const Size(0, 42),
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    _favoritesService.clearFavorites();
    _themeService.clearRecentSearches();
    setState(() {});
    Get.showSnackbar(
      const GetSnackBar(
        message: 'Signed out of guest session',
        duration: Duration(milliseconds: 1600),
        snackStyle: SnackStyle.FLOATING,
        margin: EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();
    final savedFlights = _favoritesService.getFavoriteFlightIds().length;
    final recentSearches = _themeService.getRecentSearches().length;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Get.back(),
              )
            : null,
        title: const Text(AppStrings.profile),
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.xs,
          AppSpacing.gutter,
          AppSpacing.lg,
        ),
        children: [
          FadeSlideIn(
            child: AppSurfaceCard(
              glow: true,
              padding: const EdgeInsets.all(AppSpacing.md + 2),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.16),
                  theme.colorScheme.secondary.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.brandGradient,
                        ),
                        child: Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.cardTheme.color,
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Guest User',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'guest@skytrack.app',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            MetaChip(
                              label: 'GUEST',
                              icon: Icons.verified_user_outlined,
                              color: theme.colorScheme.primary,
                              dense: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Divider(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _ProfileStat(
                          value: savedFlights,
                          label: 'Saved flights',
                          icon: Icons.favorite_rounded,
                          color: AppColors.accentMagenta,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 34,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      Expanded(
                        child: _ProfileStat(
                          value: recentSearches,
                          label: 'Recent searches',
                          icon: Icons.history_rounded,
                          color: AppColors.accentCyan,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACCOUNT',
                  style: AppTextStyles.overline.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppSurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _MenuTile(
                        icon: Icons.favorite_border_rounded,
                        title: AppStrings.favorites,
                        subtitle: '$savedFlights saved',
                        accent: AppColors.accentMagenta,
                        onTap: () async {
                          await Get.toNamed(AppRoutes.favorites);
                          if (mounted) setState(() {});
                        },
                      ),
                      _divider(theme),
                      _MenuTile(
                        icon: Icons.notifications_none_rounded,
                        title: AppStrings.notifications,
                        subtitle: 'Flight status alerts',
                        accent: AppColors.accentViolet,
                        onTap: () => Get.toNamed(AppRoutes.notifications),
                      ),
                      _divider(theme),
                      _MenuTile(
                        icon: Icons.settings_outlined,
                        title: AppStrings.settings,
                        subtitle: 'Theme and preferences',
                        accent: AppColors.accentCyan,
                        onTap: () => Get.toNamed(AppRoutes.settings),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FadeSlideIn(
            delay: const Duration(milliseconds: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SUPPORT',
                  style: AppTextStyles.overline.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppSurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _MenuTile(
                        icon: Icons.info_outline_rounded,
                        title: AppStrings.about,
                        subtitle: 'Version 1.0.0',
                        accent: AppColors.warningOrange,
                        onTap: _showAbout,
                      ),
                      _divider(theme),
                      _MenuTile(
                        icon: Icons.privacy_tip_outlined,
                        title: AppStrings.privacyPolicy,
                        subtitle: 'How your data is handled',
                        accent: AppColors.successGreen,
                        onTap: _showPrivacy,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: OutlinedButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(AppStrings.logout),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.errorRed,
                  side: BorderSide(
                    color: AppColors.errorRed.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'SkyTrack · Live Flight Tracker',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.55,
                ),
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Divider(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final int value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedCount(
              value: value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFeatures: AppTextStyles.tabular,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 13,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: accent.withValues(alpha: 0.22)),
                ),
                child: Icon(icon, size: 17, color: accent),
              ),
              const SizedBox(width: AppSpacing.sm + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
