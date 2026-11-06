import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sky_tracker/app/constants/app_colors.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/routes/app_routes.dart';
import 'package:sky_tracker/core/widgets/animated_widgets.dart';
import 'package:sky_tracker/core/widgets/common_widgets.dart';
import 'package:sky_tracker/core/widgets/responsive_layout.dart';
import 'package:sky_tracker/data/models/booking_model.dart';
import 'package:sky_tracker/data/models/flight_model.dart';

class BookingSearchPage extends StatefulWidget {
  const BookingSearchPage({super.key});

  @override
  State<BookingSearchPage> createState() => _BookingSearchPageState();
}

class _BookingSearchPageState extends State<BookingSearchPage> {
  // Trip type
  String _tripType = 'one-way';

  // Cities
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  String _fromCity = '';
  String _toCity = '';

  // Date
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _returnDate;

  // Passengers
  int _adults = 1;
  int _children = 0;
  int _infants = 0;
  String _cabinClass = 'economy';

  // Search results
  List<FlightModel> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _error;

  // Popular airports for suggestions
  static const List<Map<String, String>> _airports = [
    {'code': 'DAC', 'name': 'Dhaka'},
    {'code': 'DXB', 'name': 'Dubai'},
    {'code': 'LHR', 'name': 'London'},
    {'code': 'JFK', 'name': 'New York'},
    {'code': 'CDG', 'name': 'Paris'},
    {'code': 'NRT', 'name': 'Tokyo'},
    {'code': 'SIN', 'name': 'Singapore'},
    {'code': 'BKK', 'name': 'Bangkok'},
    {'code': 'IST', 'name': 'Istanbul'},
    {'code': 'DOH', 'name': 'Doha'},
    {'code': 'KUL', 'name': 'Kuala Lumpur'},
    {'code': 'BOM', 'name': 'Mumbai'},
    {'code': 'DEL', 'name': 'Delhi'},
    {'code': 'ATL', 'name': 'Atlanta'},
    {'code': 'LAX', 'name': 'Los Angeles'},
  ];

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _swapCities() {
    setState(() {
      final tempCity = _fromCity;
      final tempCode = _fromController.text;
      _fromCity = _toCity;
      _fromController.text = _toController.text;
      _toCity = tempCity;
      _toController.text = tempCode;
    });
  }

  Future<void> _pickDate(bool isReturn) async {
    final initialDate = isReturn ? _returnDate ?? _selectedDate.add(const Duration(days: 1)) : _selectedDate;
    final firstDate = isReturn ? _selectedDate : DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isReturn) {
          _returnDate = picked;
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  void _adjustPassengers(String type, int delta) {
    setState(() {
      switch (type) {
        case 'adults':
          _adults = (_adults + delta).clamp(1, 9);
          break;
        case 'children':
          _children = (_children + delta).clamp(0, 8);
          break;
        case 'infants':
          _infants = (_infants + delta).clamp(0, _adults);
          break;
      }
    });
  }

  void _selectAirport(Map<String, String> airport, bool isFrom) {
    setState(() {
      if (isFrom) {
        _fromController.text = airport['code']!;
        _fromCity = airport['name']!;
      } else {
        _toController.text = airport['code']!;
        _toCity = airport['name']!;
      }
    });
  }

  Future<void> _searchFlights() async {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      setState(() => _error = 'Please select departure and arrival cities.');
      return;
    }
    if (_fromController.text == _toController.text) {
      setState(() => _error = 'Departure and arrival cities must be different.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _hasSearched = true;
    });

    // Simulate search delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate mock flight results
    final random = _createRandom();
    final airlines = [
      {'code': 'BD', 'name': 'Biman Bangladesh Airlines'},
      {'code': 'EK', 'name': 'Emirates'},
      {'code': 'QR', 'name': 'Qatar Airways'},
      {'code': 'TK', 'name': 'Turkish Airlines'},
      {'code': 'SQ', 'name': 'Singapore Airlines'},
      {'code': 'AI', 'name': 'Air India'},
      {'code': 'BA', 'name': 'British Airways'},
      {'code': 'TG', 'name': 'Thai Airways'},
    ];

    final results = <FlightModel>[];
    final count = 4 + random.nextInt(5);

    for (int i = 0; i < count; i++) {
      final airline = airlines[random.nextInt(airlines.length)];
      final depHour = 6 + random.nextInt(16);
      final durationHours = 2 + random.nextInt(10);
      final arrHour = (depHour + durationHours + (depHour + durationHours >= 24 ? -24 : 0));

      final depTime = DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, depHour, random.nextInt(60)));
      final arrTime = DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, arrHour, random.nextInt(60)));

      results.add(FlightModel.mock(
        flightId: 'BK-${airline['code']!}${100 + i}',
        flightNumber: '${airline['code']!}${100 + i * 3}',
        airlineName: airline['name']!,
        depIata: _fromController.text.toUpperCase(),
        arrIata: _toController.text.toUpperCase(),
        depAirportName: _fromCity,
        arrAirportName: _toCity,
        scheduledDeparture: depTime,
        scheduledArrival: arrTime,
        statusText: 'scheduled',
      ));
    }

    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  Random _createRandom() {
    return Random(_selectedDate.hashCode ^ _fromController.text.hashCode);
  }

  void _onBookFlight(FlightModel flight) {
    final criteria = FlightSearchCriteria(
      departureCity: _fromCity,
      arrivalCity: _toCity,
      date: _selectedDate,
      adultCount: _adults,
      childCount: _children,
      infantCount: _infants,
      cabinClass: _cabinClass,
    );
    Get.toNamed(
      AppRoutes.seatSelection,
      arguments: {'flight': flight, 'criteria': criteria},
    );
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
        title: const Text('Book a Flight'),
        actions: [
          if (context.isDesktop)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Text(
                '${_adults + _children + _infants} passenger${(_adults + _children + _infants) > 1 ? 's' : ''}',
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
      body: ResponsiveContainer(
        child: Column(
          children: [
            // Search Form
            FadeSlideIn(
              child: AppSurfaceCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trip type selector
                    SegmentedTabs<String>(
                      options: const [
                        SegmentOption(value: 'one-way', label: 'One way'),
                        SegmentOption(value: 'round-trip', label: 'Round trip'),
                      ],
                      value: _tripType,
                      onChanged: (val) => setState(() => _tripType = val),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // From / To
                    Row(
                      children: [
                        Expanded(
                          child: _CitySelector(
                            label: 'From',
                            controller: _fromController,
                            city: _fromCity,
                            isFrom: true,
                            airports: _airports,
                            onSelect: _selectAirport,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AnimatedPressable(
                          onTap: _swapCities,
                          pressedScale: 0.9,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(color: theme.colorScheme.outlineVariant),
                            ),
                            child: Icon(
                              Icons.swap_horiz_rounded,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _CitySelector(
                            label: 'To',
                            controller: _toController,
                            city: _toCity,
                            isFrom: false,
                            airports: _airports,
                            onSelect: _selectAirport,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: _DateChip(
                            label: 'Depart',
                            date: _selectedDate,
                            onTap: () => _pickDate(false),
                          ),
                        ),
                        if (_tripType == 'round-trip') ...[
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _DateChip(
                              label: 'Return',
                              date: _returnDate ?? _selectedDate.add(const Duration(days: 7)),
                              onTap: () => _pickDate(true),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Passengers & Cabin
                    Row(
                      children: [
                        Expanded(
                          child: _PassengerChip(
                            adults: _adults,
                            children: _children,
                            infants: _infants,
                            onTap: () => _showPassengerDialog(context),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _CabinSelector(
                            selected: _cabinClass,
                            onChanged: (val) => setState(() => _cabinClass = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Search button
                    SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonHeight,
                      child: AnimatedPressable(
                        onTap: _isLoading ? null : _searchFlights,
                        pressedScale: 0.98,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.search_rounded, size: 19, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'Search Flights',
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
                  ],
                ),
              ),
            ),

            // Error
            if (_error != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  _error!,
                  style: TextStyle(color: AppColors.errorRed, fontSize: 13),
                ),
              ),
            ],

            // Results
            Expanded(
              child: _isLoading
                  ? const FlightListSkeleton(itemCount: 3)
                  : _hasSearched
                      ? _ResultsList(results: _results, onBook: _onBookFlight)
                      : _EmptySearch(),
            ),
          ],
        ),
      ),
    );
  }

  void _showPassengerDialog(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Passengers & Class', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                _PassengerRow(
                  label: 'Adults',
                  subtitle: '12+ years',
                  count: _adults,
                  onAdd: () => _adjustPassengers('adults', 1),
                  onRemove: () => _adjustPassengers('adults', -1),
                ),
                _PassengerRow(
                  label: 'Children',
                  subtitle: '2-11 years',
                  count: _children,
                  onAdd: () => _adjustPassengers('children', 1),
                  onRemove: () => _adjustPassengers('children', -1),
                ),
                _PassengerRow(
                  label: 'Infants',
                  subtitle: 'Under 2 years',
                  count: _infants,
                  onAdd: () => _adjustPassengers('infants', 1),
                  onRemove: () => _adjustPassengers('infants', -1),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Get.back(),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CitySelector extends StatelessWidget {
  const _CitySelector({
    required this.label,
    required this.controller,
    required this.city,
    required this.isFrom,
    required this.airports,
    required this.onSelect,
  });

  final String label;
  final TextEditingController controller;
  final String city;
  final bool isFrom;
  final List<Map<String, String>> airports;
  final void Function(Map<String, String>, bool) onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _showAirportPicker(context),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
            const SizedBox(height: 2),
            if (controller.text.isNotEmpty)
              Row(
                children: [
                  Text(
                    controller.text,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      city,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            else
              Text(
                'Select city',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAirportPicker(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: airports.map((airport) {
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Center(
                    child: Text(
                      airport['code']!,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                title: Text(airport['name']!),
                subtitle: Text(airport['code']!),
                onTap: () {
                  onSelect(airport, isFrom);
                  Get.back();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatted = DateFormat('EEE, d MMM').format(date);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
            const SizedBox(height: 2),
            Text(
              formatted,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PassengerChip extends StatelessWidget {
  const _PassengerChip({
    required this.adults,
    required this.children,
    required this.infants,
    required this.onTap,
  });

  final int adults;
  final int children;
  final int infants;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = <String>[];
    if (adults > 0) parts.add('$adults A');
    if (children > 0) parts.add('$children C');
    if (infants > 0) parts.add('$infants I');
    final label = parts.isEmpty ? '1 A' : parts.join(' / ');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Passengers', style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CabinSelector extends StatelessWidget {
  const _CabinSelector({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedTabs<String>(
      options: const [
        SegmentOption(value: 'economy', label: 'Economy'),
        SegmentOption(value: 'business', label: 'Business'),
        SegmentOption(value: 'first', label: 'First'),
      ],
      value: selected,
      onChanged: onChanged,
      height: 44,
    );
  }
}

class _PassengerRow extends StatelessWidget {
  const _PassengerRow({
    required this.label,
    required this.subtitle,
    required this.count,
    required this.onAdd,
    required this.onRemove,
  });

  final String label;
  final String subtitle;
  final int count;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Row(
            children: [
              AnimatedPressable(
                onTap: count > (label == 'Adults' ? 1 : 0) ? onRemove : null,
                pressedScale: 0.9,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Center(
                    child: Text(
                      '−',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: count > (label == 'Adults' ? 1 : 0)
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$count',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 12),
              AnimatedPressable(
                onTap: onAdd,
                pressedScale: 0.9,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Icon(Icons.add_rounded, size: 18, color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.results, required this.onBook});

  final List<FlightModel> results;
  final void Function(FlightModel) onBook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (results.isEmpty) {
      return EmptyStateWidget(
        key: const ValueKey('empty'),
        title: 'No flights found',
        subtitle: 'Try different cities or dates.',
        icon: Icons.flight_rounded,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Text('Available Flights', style: theme.textTheme.titleMedium?.copyWith(fontSize: 15)),
              const SizedBox(width: AppSpacing.sm),
              MetaChip(label: '${results.length}', color: theme.colorScheme.primary, dense: true),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.lg),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final flight = results[index];
              return FadeSlideIn(
                delay: Duration(milliseconds: 60 * (index % 6)),
                child: _BookingFlightCard(flight: flight, onBook: onBook),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BookingFlightCard extends StatelessWidget {
  const _BookingFlightCard({required this.flight, required this.onBook});

  final FlightModel flight;
  final void Function(FlightModel) onBook;

  String _shortTime(String? raw) {
    if (raw == null || raw.isEmpty) return '--:--';
    try {
      final parts = raw.split(' ');
      if (parts.length >= 2) {
        final timePart = parts[1].split(':');
        if (timePart.length >= 2) return '${timePart[0]}:${timePart[1]}';
      }
      return raw;
    } catch (_) {
      return raw;
    }
  }

  String _duration(String? departure, String? arrival) {
    if (departure == null || arrival == null) return '—';
    try {
      final dep = DateTime.tryParse(departure.replaceFirst(' ', 'T'));
      final arr = DateTime.tryParse(arrival.replaceFirst(' ', 'T'));
      if (dep == null || arr == null) return '—';
      final minutes = arr.difference(dep).inMinutes.abs();
      if (minutes == 0) return '—';
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return h == 0 ? '${m}m' : '${h}h ${m.toString().padLeft(2, '0')}m';
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppSurfaceCard(
        onTap: () => onBook(flight),
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm + 2),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.22),
                        theme.colorScheme.secondary.withValues(alpha: 0.12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.22)),
                  ),
                  child: Icon(Icons.flight_rounded, size: 20, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: AppSpacing.sm + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flight.flightNumber,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        flight.airlineName,
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                MetaChip(label: 'Book', color: AppColors.successGreen, dense: true),
              ],
            ),
            const SizedBox(height: AppSpacing.md + 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flight.depIata.isNotEmpty ? flight.depIata : '—',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        flight.depAirportName,
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _shortTime(flight.scheduledDeparture),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 80,
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      AnimatedFlightPath(
                        color: theme.colorScheme.primary,
                        height: 18,
                        planeSize: 13,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _duration(flight.scheduledDeparture, flight.scheduledArrival),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          letterSpacing: 0.4,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        flight.arrIata.isNotEmpty ? flight.arrIata : '—',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        flight.arrAirportName,
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _shortTime(flight.scheduledArrival),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      key: const ValueKey('idle'),
      title: 'Find your flight',
      subtitle: 'Select cities, date and passengers to search for available flights.',
      icon: Icons.flight_takeoff_rounded,
    );
  }
}
