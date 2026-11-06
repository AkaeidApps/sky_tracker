import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sky_tracker/app/constants/app_colors.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/constants/app_strings.dart';
import 'package:sky_tracker/app/constants/app_text_styles.dart';
import 'package:sky_tracker/app/routes/app_routes.dart';
import 'package:sky_tracker/core/error/exceptions.dart';
import 'package:sky_tracker/core/widgets/animated_widgets.dart';
import 'package:sky_tracker/core/widgets/common_widgets.dart';
import 'package:sky_tracker/core/widgets/flight_card.dart';
import 'package:sky_tracker/data/models/flight_model.dart';
import 'package:sky_tracker/data/repositories/flight_repository.dart';

class AirportExplorerPage extends StatefulWidget {
  const AirportExplorerPage({super.key});

  @override
  State<AirportExplorerPage> createState() => _AirportExplorerPageState();
}

class _AirportExplorerPageState extends State<AirportExplorerPage> {
  final TextEditingController _searchController = TextEditingController();
  final FlightRepository _repository = FlightRepository();

  List<FlightModel> _flights = [];
  List<_AirportInfo> _airports = [];
  bool _isLoading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadFlights();
  }

  void _onSearchChanged() {
    final value = _searchController.text.trim();
    if (value == _query) return;
    setState(() => _query = value);
  }

  Future<void> _loadFlights() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final flights = await _repository.getFlights(limit: 50);
      if (!mounted) return;
      setState(() {
        _flights = flights;
        _airports = _aggregateAirports(flights);
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

  List<_AirportInfo> _aggregateAirports(List<FlightModel> flights) {
    final map = <String, _AirportInfo>{};
    for (final flight in flights) {
      final iata = flight.depIata;
      if (iata.isEmpty) continue;
      final existing = map[iata];
      if (existing == null) {
        map[iata] = _AirportInfo(
          iata: iata,
          name: flight.depAirportName,
          departures: 1,
        );
      } else {
        existing.departures += 1;
      }
    }
    final list = map.values.toList()
      ..sort((a, b) => b.departures.compareTo(a.departures));
    return list;
  }

  List<_AirportInfo> get _filteredAirports {
    if (_query.isEmpty) return _airports;
    final q = _query.toLowerCase();
    return _airports
        .where(
          (a) =>
              a.iata.toLowerCase().contains(q) ||
              a.name.toLowerCase().contains(q),
        )
        .toList();
  }

  List<FlightModel> _departuresFor(String iata) {
    return _flights.where((f) => f.depIata == iata).toList();
  }

  void _openAirport(_AirportInfo airport) {
    final departures = _departuresFor(airport.iata);
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.94,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusXl),
                ),
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      AppSpacing.md,
                      AppSpacing.gutter,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.13,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm + 2,
                            ),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              airport.iata,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontFeatures: AppTextStyles.tabular,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm + 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                airport.name,
                                style: theme.textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${departures.length} live departures',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        MetaChip(
                          label: 'LIVE',
                          color: AppColors.successGreen,
                          dense: true,
                        ),
                      ],
                    ),
                  ),
                  Divider(color: theme.colorScheme.outlineVariant),
                  Expanded(
                    child: departures.isEmpty
                        ? const EmptyStateWidget(
                            title: 'No departures',
                            subtitle: 'No live departures for this airport.',
                            icon: Icons.flight_takeoff_rounded,
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.gutter,
                              AppSpacing.md,
                              AppSpacing.gutter,
                              AppSpacing.lg,
                            ),
                            itemCount: departures.length,
                            itemBuilder: (context, index) {
                              final flight = departures[index];
                              return FadeSlideIn(
                                delay: Duration(milliseconds: 50 * (index % 6)),
                                child: FlightCard(
                                  flight: flight,
                                  onTap: () {
                                    Navigator.of(sheetContext).pop();
                                    Get.toNamed(
                                      AppRoutes.flightDetails,
                                      arguments: flight,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredAirports;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Get.back(),
              )
            : null,
        title: const Text(AppStrings.airportExplorer),
      ),
      body: RefreshIndicator(
        onRefresh: _loadFlights,
        color: theme.colorScheme.primary,
        backgroundColor: theme.cardTheme.color,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.xs,
                  AppSpacing.gutter,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeSlideIn(
                      child: Text(
                        'EXPLORE',
                        style: AppTextStyles.overline.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 50),
                      child: Text(
                        'Airports with live departures',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 80),
                      child: Text(
                        '${_airports.length} airports · ${_flights.length} tracked flights',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 110),
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: AppStrings.airportSearch,
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 20,
                          ),
                          suffixIcon: AnimatedSwitcher(
                            duration: AppMotion.fast,
                            child: _query.isEmpty
                                ? const SizedBox.shrink()
                                : IconButton(
                                    key: const ValueKey('clear'),
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Text(
                          _query.isEmpty ? 'All airports' : 'Results',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        MetaChip(
                          label: '${filtered.length}',
                          color: theme.colorScheme.primary,
                          dense: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutter,
                  ),
                  child: Column(
                    children: List.generate(
                      6,
                      (index) => const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ShimmerBox(
                          height: 76,
                          radius: AppSpacing.radiusLg,
                        ),
                      ),
                    ),
                  ),
                ),
              )
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
            else if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: EmptyStateWidget(
                    title: _query.isEmpty
                        ? 'No airports found'
                        : 'No matches for "$_query"',
                    subtitle: _query.isEmpty
                        ? 'Live airport data will appear here.'
                        : 'Try a different airport code or city name.',
                    icon: Icons.travel_explore_rounded,
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final airport = filtered[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      0,
                      AppSpacing.gutter,
                      AppSpacing.sm,
                    ),
                    child: FadeSlideIn(
                      delay: Duration(milliseconds: 40 * (index % 10)),
                      child: _AirportCard(
                        airport: airport,
                        onTap: () => _openAirport(airport),
                      ),
                    ),
                  );
                }, childCount: filtered.length),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          ],
        ),
      ),
    );
  }
}

class _AirportCard extends StatelessWidget {
  const _AirportCard({required this.airport, required this.onTap});

  final _AirportInfo airport;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.20),
                  theme.colorScheme.secondary.withValues(alpha: 0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.22),
              ),
            ),
            child: Center(
              child: Text(
                airport.iata,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  fontFeatures: AppTextStyles.tabular,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  airport.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    PulseDot(
                      color: AppColors.successGreen,
                      size: 4,
                      pulseScale: 2.4,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${airport.departures} live departures',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

class _AirportInfo {
  _AirportInfo({
    required this.iata,
    required this.name,
    required this.departures,
  });

  final String iata;
  final String name;
  int departures;
}
