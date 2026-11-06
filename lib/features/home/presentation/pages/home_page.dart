import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sky_tracker/app/constants/app_colors.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/constants/app_strings.dart';
import 'package:sky_tracker/app/constants/app_text_styles.dart';
import 'package:sky_tracker/app/routes/app_routes.dart';
import 'package:sky_tracker/core/error/exceptions.dart';
import 'package:sky_tracker/core/services/favorites_service.dart';
import 'package:sky_tracker/core/services/theme_service.dart';
import 'package:sky_tracker/core/widgets/animated_widgets.dart';
import 'package:sky_tracker/core/widgets/common_widgets.dart';
import 'package:sky_tracker/core/widgets/flight_card.dart';
import 'package:sky_tracker/core/widgets/responsive_layout.dart';
import 'package:sky_tracker/data/models/flight_model.dart';
import 'package:sky_tracker/data/repositories/flight_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlightRepository _repository = FlightRepository();
  final ThemeService _themeService = ThemeService();
  final FavoritesService _favoritesService = Get.find<FavoritesService>();

  List<FlightModel> _flights = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  Future<void> _loadFlights() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final flights = await _repository.getFlights(limit: 10);
      if (!mounted) return;
      setState(() {
        _flights = flights;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'An unexpected error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  int get _activeFlights => _flights
      .where(
        (f) =>
            f.statusText.toLowerCase() == 'active' ||
            f.statusText.toLowerCase() == 'in air',
      )
      .length;

  Future<void> _openSearch([String? query]) async {
    await Get.toNamed(AppRoutes.flightSearch, arguments: query);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recentSearches = _themeService.getRecentSearches();

    return Scaffold(
      body: Stack(
        children: [
          // Ambient brand glow behind the header
          Positioned(
            top: -150,
            right: -110,
            child: IgnorePointer(
              child: Container(
                width: context.isDesktop ? 420 : 320,
                height: context.isDesktop ? 420 : 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(
                        alpha: theme.brightness == Brightness.dark
                            ? 0.16
                            : 0.10,
                      ),
                      theme.colorScheme.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: _loadFlights,
            color: theme.colorScheme.primary,
            backgroundColor: theme.cardTheme.color,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.gutter,
                        AppSpacing.sm,
                        AppSpacing.gutter,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(
                            greeting: _getGreeting(),
                            onNotifications: () =>
                                Get.toNamed(AppRoutes.notifications),
                            onProfile: () => Get.toNamed(AppRoutes.profile),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _SearchBar(onTap: _openSearch),
                          if (recentSearches.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            _RecentSearches(
                              searches: recentSearches,
                              onTap: _openSearch,
                              onClear: () {
                                _themeService.clearRecentSearches();
                                setState(() {});
                              },
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          _QuickActions(
                            favoritesCount: _favoritesService
                                .getFavoriteFlightIds()
                                .length,
                            onMap: () => Get.toNamed(AppRoutes.liveMap),
                            onAirports: () =>
                                Get.toNamed(AppRoutes.airportExplorer),
                            onFavorites: () => Get.toNamed(AppRoutes.favorites),
                            onBooking: () => Get.toNamed(AppRoutes.bookingSearch),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _StatsStrip(
                            total: _flights.length,
                            active: _activeFlights,
                            favorites: _favoritesService
                                .getFavoriteFlightIds()
                                .length,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _LiveHeader(count: _flights.length),
                          const SizedBox(height: AppSpacing.xs),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isLoading)
                  const SliverToBoxAdapter(child: _HomeSkeleton())
                else if (_error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.lg),
                      child: ErrorStateWidget(
                        message: _error!,
                        onRetry: _loadFlights,
                      ),
                    ),
                  )
                else if (_flights.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.lg),
                      child: EmptyStateWidget(
                        title: 'No live flights right now',
                        subtitle: 'Try searching for a specific flight number to see its status.',
                        icon: Icons.flight_takeoff_rounded,
                        action: FilledButton.icon(
                          onPressed: _openSearch,
                          icon: const Icon(Icons.search_rounded, size: 18),
                          label: const Text('Search flights'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(170, 46),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final flight = _flights[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.gutter,
                        ),
                        child: FadeSlideIn(
                          delay: Duration(milliseconds: 60 * (index % 8)),
                          child: FlightCard(
                            flight: flight,
                            onTap: () => Get.toNamed(
                              AppRoutes.flightDetails,
                              arguments: flight,
                            ),
                          ),
                        ),
                      );
                    }, childCount: _flights.length),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.lg),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.greeting,
    required this.onNotifications,
    required this.onProfile,
  });

  final String greeting;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeSlideIn(
      offset: const Offset(0, 0.05),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, d MMMM')
                      .format(DateTime.now())
                      .toUpperCase(),
                  style: AppTextStyles.overline.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  greeting,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Where are you flying today?',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SkyIconButton(
            icon: Icons.notifications_none_rounded,
            showDot: true,
            onPressed: onNotifications,
            tooltip: 'Notifications',
          ),
          const SizedBox(width: AppSpacing.sm),
          AnimatedPressable(
            onTap: onProfile,
            pressedScale: 0.92,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 21,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final Future<void> Function([String?]) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeSlideIn(
      delay: const Duration(milliseconds: 80),
      child: AppSurfaceCard(
        onTap: () => onTap(),
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
                color: theme.colorScheme.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(
                Icons.search_rounded,
                size: 19,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Text(
                AppStrings.searchFlight,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.tune_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({
    required this.searches,
    required this.onTap,
    required this.onClear,
  });

  final List<String> searches;
  final Future<void> Function([String?]) onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeSlideIn(
      delay: const Duration(milliseconds: 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onClear,
                child: Text(
                  'Clear',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: searches.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                return AnimatedPressable(
                  onTap: () => onTap(searches[index]),
                  pressedScale: 0.94,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          searches[index],
                          style: AppTextStyles.caption.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.favoritesCount,
    required this.onMap,
    required this.onAirports,
    required this.onFavorites,
    required this.onBooking,
  });

  final int favoritesCount;
  final VoidCallback onMap;
  final VoidCallback onAirports;
  final VoidCallback onFavorites;
  final VoidCallback onBooking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 160),
                child: _QuickActionCard(
                  icon: Icons.public_rounded,
                  label: 'Live Map',
                  color: AppColors.accentCyan,
                  onTap: onMap,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 210),
                child: _QuickActionCard(
                  icon: Icons.travel_explore_rounded,
                  label: 'Airports',
                  color: AppColors.accentViolet,
                  onTap: onAirports,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 260),
                child: _QuickActionCard(
                  icon: Icons.favorite_rounded,
                  label: 'Favorites',
                  color: AppColors.accentMagenta,
                  badge: favoritesCount > 0 ? '$favoritesCount' : null,
                  onTap: onFavorites,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        FadeSlideIn(
          delay: const Duration(milliseconds: 310),
          child: _BookingActionCard(onTap: onBooking),
        ),
      ],
    );
  }
}

/// Full-width booking action card with gradient background.
class _BookingActionCard extends StatelessWidget {
  const _BookingActionCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md + 2,
      ),
      gradient: LinearGradient(
        colors: [
          AppColors.accentCyan.withValues(alpha: 0.18),
          AppColors.accentViolet.withValues(alpha: 0.12),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
            ),
            child: const Icon(
              Icons.airplane_ticket_rounded,
              size: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book a Flight',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Search & book tickets for your next trip',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_rounded,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const Spacer(),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    badge!,
                    style: AppTextStyles.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.6,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({
    required this.total,
    required this.active,
    required this.favorites,
  });

  final int total;
  final int active;
  final int favorites;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeSlideIn(
      delay: const Duration(milliseconds: 300),
      child: AppSurfaceCard(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: _Stat(label: 'Tracked', value: total),
            ),
            _divider(theme),
            Expanded(
              child: _Stat(
                label: 'In air',
                value: active,
                color: AppColors.successGreen,
                live: active > 0,
              ),
            ),
            _divider(theme),
            Expanded(
              child: _Stat(
                label: 'Saved',
                value: favorites,
                color: AppColors.accentMagenta,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(ThemeData theme) {
    return Container(
      width: 1,
      height: 30,
      color: theme.colorScheme.outlineVariant,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.color,
    this.live = false,
  });

  final String label;
  final int value;
  final Color? color;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (live) ...[
              PulseDot(
                color: color ?? theme.colorScheme.primary,
                size: 5,
                pulseScale: 2.4,
              ),
              const SizedBox(width: 4),
            ],
            AnimatedCount(
              value: value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFeatures: AppTextStyles.tabular,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
      ],
    );
  }
}

class _LiveHeader extends StatelessWidget {
  const _LiveHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          AppStrings.liveFlights,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        MetaChip(
          label: '$count',
          color: theme.colorScheme.primary,
          dense: true,
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Get.toNamed(AppRoutes.flightSearch),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            visualDensity: VisualDensity.compact,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('See all'),
              SizedBox(width: 2),
              Icon(Icons.arrow_forward_rounded, size: 14),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Column(
        children: List.generate(3, (index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: ShimmerBox(height: 150, radius: AppSpacing.radiusLg),
          );
        }),
      ),
    );
  }
}
