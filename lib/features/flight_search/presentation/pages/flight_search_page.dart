import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sky_tracker/app/constants/app_colors.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/constants/app_strings.dart';
import 'package:sky_tracker/app/constants/app_text_styles.dart';
import 'package:sky_tracker/app/routes/app_routes.dart';
import 'package:sky_tracker/core/error/exceptions.dart';
import 'package:sky_tracker/core/services/theme_service.dart';
import 'package:sky_tracker/core/widgets/animated_widgets.dart';
import 'package:sky_tracker/core/widgets/common_widgets.dart';
import 'package:sky_tracker/core/widgets/flight_card.dart';
import 'package:sky_tracker/core/widgets/responsive_layout.dart';
import 'package:sky_tracker/data/models/flight_model.dart';
import 'package:sky_tracker/data/repositories/flight_repository.dart';

class FlightSearchPage extends StatefulWidget {
  const FlightSearchPage({super.key});

  @override
  State<FlightSearchPage> createState() => _FlightSearchPageState();
}

class _FlightSearchPageState extends State<FlightSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FlightRepository _repository = FlightRepository();
  final ThemeService _themeService = ThemeService();

  List<FlightModel> _results = [];
  bool _isLoading = false;
  String? _error;
  String _lastQuery = '';
  bool _hasSearched = false;

  static const List<String> _suggestions = ['BA123', 'EK202', 'AI101'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onTextChanged);
    final args = Get.arguments as String?;
    if (args != null && args.isNotEmpty) {
      _searchController.text = args;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFlights(args);
      });
    }
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _searchFlights(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() => _results = []);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _error = null;
      _lastQuery = trimmed;
      _hasSearched = true;
    });

    try {
      final results = await _repository.getFlights(flightNumber: trimmed);
      if (!mounted) return;
      setState(() {
        _results = results;
        _isLoading = false;
      });
      _themeService.addRecentSearch(trimmed);
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

  void _clear() {
    _searchController.clear();
    setState(() {
      _results = [];
      _error = null;
      _hasSearched = false;
      _lastQuery = '';
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onTextChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        title: const Text(AppStrings.flightSearch),
      ),
      body: ResponsiveContainer(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.xs,
                AppSpacing.gutter,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.search,
                      textCapitalization: TextCapitalization.characters,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. BA123',
                        prefixIcon: Icon(
                          Icons.flight_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        suffixIcon: AnimatedSwitcher(
                          duration: AppMotion.fast,
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: _searchController.text.isEmpty
                              ? const SizedBox.shrink(key: ValueKey('empty'))
                              : IconButton(
                                  key: const ValueKey('clear'),
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  onPressed: _clear,
                                ),
                        ),
                      ),
                      onSubmitted: _searchFlights,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm + 2),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: Row(
                      children: [
                        Text(
                          'Try',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        ..._suggestions.map(
                          (code) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: AnimatedPressable(
                              onTap: () {
                                _searchController.text = code;
                                _searchFlights(code);
                              },
                              pressedScale: 0.94,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
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
                                child: Text(
                                  code,
                                  style: AppTextStyles.label.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_searchController.text.length}/10',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonHeight,
                      child: AnimatedPressable(
                        onTap: _isLoading
                            ? null
                            : () => _searchFlights(_searchController.text),
                        pressedScale: 0.98,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                          child: AnimatedSwitcher(
                            duration: AppMotion.fast,
                            child: _isLoading
                                ? const SizedBox(
                                    key: ValueKey('loading'),
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Row(
                                    key: ValueKey('label'),
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.search_rounded,
                                        size: 19,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Search flights',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ),
                ],
              ),
            ),
            Divider(color: theme.colorScheme.outlineVariant),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.normal,
                child: _buildResults(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(ThemeData theme) {
    if (_isLoading) {
      return const FlightListSkeleton(key: ValueKey('skeleton'), itemCount: 3);
    }
    if (_error != null) {
      return ErrorStateWidget(
        key: const ValueKey('error'),
        message: _error!,
        onRetry: () => _searchFlights(_lastQuery),
      );
    }
    if (!_hasSearched) {
      return EmptyStateWidget(
        key: const ValueKey('idle'),
        title: 'Track any flight',
        subtitle: 'Enter a flight number to see live status, route, aircraft and gate details.',
        icon: Icons.radar_rounded,
      );
    }
    if (_results.isEmpty) {
      return EmptyStateWidget(
        key: const ValueKey('empty'),
        title: 'No flights found',
        subtitle: 'We could not find a flight matching "$_lastQuery".',
        icon: Icons.search_off_rounded,
      );
    }
    return Column(
      key: const ValueKey('results'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.md,
            AppSpacing.gutter,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Text(
                'Results',
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 15),
              ),
              const SizedBox(width: AppSpacing.sm),
              MetaChip(
                label: '${_results.length}',
                color: theme.colorScheme.primary,
                dense: true,
              ),
              const Spacer(),
              Text(
                _lastQuery.toUpperCase(),
                style: AppTextStyles.overline.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              0,
              AppSpacing.gutter,
              AppSpacing.lg,
            ),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final flight = _results[index];
              return FadeSlideIn(
                delay: Duration(milliseconds: 60 * (index % 6)),
                child: FlightCard(
                  flight: flight,
                  onTap: () =>
                      Get.toNamed(AppRoutes.flightDetails, arguments: flight),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
