import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/constants/app_strings.dart';
import 'package:sky_tracker/app/routes/app_routes.dart';
import 'package:sky_tracker/core/error/exceptions.dart';
import 'package:sky_tracker/core/services/favorites_service.dart';
import 'package:sky_tracker/core/widgets/animated_widgets.dart';
import 'package:sky_tracker/core/widgets/common_widgets.dart';
import 'package:sky_tracker/core/widgets/flight_card.dart';
import 'package:sky_tracker/data/models/flight_model.dart';
import 'package:sky_tracker/data/repositories/flight_repository.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesService _favoritesService = Get.find<FavoritesService>();
  final FlightRepository _repository = FlightRepository();
  List<FlightModel> _favoriteFlights = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final favoriteIds = _favoritesService.getFavoriteFlightIds();
      if (favoriteIds.isEmpty) {
        if (!mounted) return;
        setState(() {
          _favoriteFlights = [];
          _isLoading = false;
        });
        return;
      }
      final allFlights = await _repository.getFlights(limit: 100);
      if (!mounted) return;
      setState(() {
        _favoriteFlights = allFlights
            .where((f) => favoriteIds.contains(f.flightId))
            .toList();
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

  void _removeFavorite(FlightModel flight, int index) {
    final flightId = flight.flightId ?? '';
    _favoritesService.removeFavorite(flightId);
    setState(() {
      _favoriteFlights.removeWhere((f) => f.flightId == flightId);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${flight.flightNumber} removed from favorites'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _favoritesService.addFavorite(flightId);
            if (!mounted) return;
            setState(() {
              final insertAt = index.clamp(0, _favoriteFlights.length);
              _favoriteFlights.insert(insertAt, flight);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        title: const Text(AppStrings.favorites),
        actions: [
          if (!_isLoading && _favoriteFlights.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: MetaChip(
                  label: '${_favoriteFlights.length} saved',
                  color: theme.colorScheme.primary,
                  dense: true,
                ),
              ),
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: AppMotion.normal,
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Padding(
        key: ValueKey('loading'),
        padding: EdgeInsets.only(top: AppSpacing.sm),
        child: FlightListSkeleton(itemCount: 4),
      );
    }
    if (_error != null) {
      return ErrorStateWidget(
        key: const ValueKey('error'),
        message: _error!,
        onRetry: _loadFavorites,
      );
    }
    if (_favoriteFlights.isEmpty) {
      return EmptyStateWidget(
        key: const ValueKey('empty'),
        title: AppStrings.emptyFavorites,
        subtitle: AppStrings.emptyMessage,
        icon: Icons.favorite_border_rounded,
        action: FilledButton.icon(
          onPressed: () => Get.toNamed(AppRoutes.flightSearch),
          icon: const Icon(Icons.search_rounded, size: 18),
          label: const Text('Find flights'),
          style: FilledButton.styleFrom(minimumSize: const Size(160, 46)),
        ),
      );
    }

    return RefreshIndicator(
      key: const ValueKey('list'),
      onRefresh: _loadFavorites,
      color: theme.colorScheme.primary,
      backgroundColor: theme.cardTheme.color,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.sm,
          AppSpacing.gutter,
          AppSpacing.lg,
        ),
        itemCount: _favoriteFlights.length,
        itemBuilder: (context, index) {
          final flight = _favoriteFlights[index];
          return FadeSlideIn(
            delay: Duration(milliseconds: 55 * (index % 8)),
            child: Dismissible(
              key: Key(flight.flightId ?? 'fav_$index'),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => _removeFavorite(flight, index),
              background: Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.only(right: AppSpacing.lg),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF87171), Color(0xFFDC2626)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Remove',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              child: FlightCard(
                flight: flight,
                onTap: () =>
                    Get.toNamed(AppRoutes.flightDetails, arguments: flight),
              ),
            ),
          );
        },
      ),
    );
  }
}
