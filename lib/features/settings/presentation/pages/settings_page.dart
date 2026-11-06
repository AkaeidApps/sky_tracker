import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sky_tracker/app/constants/app_colors.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/constants/app_strings.dart';
import 'package:sky_tracker/app/constants/app_text_styles.dart';
import 'package:sky_tracker/core/services/favorites_service.dart';
import 'package:sky_tracker/core/services/theme_service.dart';
import 'package:sky_tracker/core/widgets/animated_widgets.dart';
import 'package:sky_tracker/core/widgets/common_widgets.dart';
import 'package:sky_tracker/data/repositories/flight_repository.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ThemeService _themeService = ThemeService();
  final FlightRepository _repository = FlightRepository();
  late final FavoritesService _favoritesService;

  String _themeMode = 'dark';
  bool? _apiConnected;
  bool _checkingApi = false;

  @override
  void initState() {
    super.initState();
    _themeMode = _themeService.getThemeMode();
    _favoritesService = Get.find<FavoritesService>();
  }

  Future<void> _checkApi() async {
    setState(() => _checkingApi = true);
    try {
      final connected = await _repository.checkConnection();
      if (!mounted) return;
      setState(() => _apiConnected = connected);
    } catch (_) {
      if (!mounted) return;
      setState(() => _apiConnected = false);
    } finally {
      if (mounted) setState(() => _checkingApi = false);
    }
  }

  void _setTheme(String mode) {
    if (mode == _themeMode) return;
    HapticFeedback.selectionClick();
    _themeService.setThemeMode(mode);
    setState(() => _themeMode = mode);
  }

  void _showToast(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        duration: const Duration(milliseconds: 1500),
        snackStyle: SnackStyle.FLOATING,
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recentCount = _themeService.getRecentSearches().length;
    final favoritesCount = _favoritesService.getFavoriteFlightIds().length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        title: const Text(AppStrings.settings),
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
            child: _Group(
              title: 'APPEARANCE',
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.accentViolet.withValues(
                                alpha: 0.13,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                              border: Border.all(
                                color: AppColors.accentViolet.withValues(
                                  alpha: 0.22,
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.palette_outlined,
                              size: 17,
                              color: AppColors.accentViolet,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm + 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.theme,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.5,
                                  ),
                                ),
                                Text(
                                  'Choose how SkyTrack looks',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SegmentedTabs<String>(
                        value: _themeMode,
                        onChanged: _setTheme,
                        options: const [
                          SegmentOption(
                            value: 'dark',
                            label: 'Dark',
                            icon: Icons.dark_mode_outlined,
                          ),
                          SegmentOption(
                            value: 'light',
                            label: 'Light',
                            icon: Icons.light_mode_outlined,
                          ),
                          SegmentOption(
                            value: 'system',
                            label: 'System',
                            icon: Icons.brightness_auto_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: _Group(
              title: 'DATA & STORAGE',
              children: [
                _SettingRow(
                  icon: Icons.history_rounded,
                  accent: AppColors.accentCyan,
                  title: AppStrings.recentSearches,
                  subtitle: '$recentCount saved searches',
                  trailing: TextButton(
                    onPressed: recentCount == 0
                        ? null
                        : () {
                            _themeService.clearRecentSearches();
                            setState(() {});
                            _showToast('Recent searches cleared');
                          },
                    child: const Text('Clear'),
                  ),
                ),
                _rowDivider(theme),
                _SettingRow(
                  icon: Icons.favorite_border_rounded,
                  accent: AppColors.accentMagenta,
                  title: AppStrings.favorites,
                  subtitle: '$favoritesCount saved flights',
                  trailing: TextButton(
                    onPressed: favoritesCount == 0
                        ? null
                        : () {
                            _favoritesService.clearFavorites();
                            setState(() {});
                            _showToast('Saved flights cleared');
                          },
                    child: const Text('Clear'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FadeSlideIn(
            delay: const Duration(milliseconds: 140),
            child: _Group(
              title: 'CONNECTION',
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      AnimatedSwitcher(
                        duration: AppMotion.normal,
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: _checkingApi
                            ? const SizedBox(
                                key: ValueKey('checking'),
                                width: 34,
                                height: 34,
                                child: Padding(
                                  padding: EdgeInsets.all(7),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : Container(
                                key: ValueKey(_apiConnected),
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: (_apiConnected ?? false)
                                      ? AppColors.successGreen.withValues(
                                          alpha: 0.13,
                                        )
                                      : theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSm,
                                  ),
                                  border: Border.all(
                                    color: (_apiConnected ?? false)
                                        ? AppColors.successGreen.withValues(
                                            alpha: 0.25,
                                          )
                                        : theme.colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Icon(
                                  _apiConnected == null
                                      ? Icons.wifi_tethering_rounded
                                      : (_apiConnected!
                                            ? Icons.check_circle_outline_rounded
                                            : Icons.error_outline_rounded),
                                  size: 17,
                                  color: _apiConnected == null
                                      ? theme.colorScheme.onSurfaceVariant
                                      : (_apiConnected!
                                            ? AppColors.successGreen
                                            : AppColors.errorRed),
                                ),
                              ),
                      ),
                      const SizedBox(width: AppSpacing.sm + 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.apiStatus,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            AnimatedSwitcher(
                              duration: AppMotion.fast,
                              child: Text(
                                _checkingApi
                                    ? 'Checking connection…'
                                    : _apiConnected == null
                                    ? 'Not checked yet'
                                    : (_apiConnected!
                                          ? AppStrings.connected
                                          : AppStrings.notConnected),
                                key: ValueKey('${_checkingApi}_$_apiConnected'),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 38,
                        child: FilledButton.tonal(
                          onPressed: _checkingApi ? null : _checkApi,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            minimumSize: const Size(0, 38),
                          ),
                          child: const Text(
                            'Check',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
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
            child: _Group(
              title: 'ABOUT',
              children: [
                _SettingRow(
                  icon: Icons.flight_rounded,
                  accent: AppColors.accentPurple,
                  title: AppStrings.appName,
                  subtitle: AppStrings.appTagline,
                  trailing: MetaChip(
                    label: 'v1.0.0',
                    color: theme.colorScheme.primary,
                    dense: true,
                  ),
                ),
                _rowDivider(theme),
                _SettingRow(
                  icon: Icons.dns_outlined,
                  accent: AppColors.warningOrange,
                  title: 'Data source',
                  subtitle: 'Aviationstack flight API',
                  trailing: Icon(
                    Icons.open_in_new_rounded,
                    size: 15,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              'Made for aviation enthusiasts',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.55,
                ),
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Divider(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.overline.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
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
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.5),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
