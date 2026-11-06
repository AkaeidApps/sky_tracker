import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sky_tracker/app/constants/app_colors.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/routes/app_routes.dart';
import 'package:sky_tracker/core/widgets/animated_widgets.dart';
import 'package:sky_tracker/core/widgets/responsive_layout.dart';
import 'package:sky_tracker/data/models/booking_model.dart';
import 'package:sky_tracker/data/models/flight_model.dart';

class SeatSelectionPage extends StatefulWidget {
  const SeatSelectionPage({super.key});

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  late final FlightModel _flight;
  late final FlightSearchCriteria _criteria;

  List<SeatModel> _seats = [];
  final Set<String> _selectedSeatIds = {};
  final Set<String> _occupiedSeatIds = {};

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _flight = args['flight'] as FlightModel;
    _criteria = args['criteria'] as FlightSearchCriteria;
    _generateSeats();
  }

  void _generateSeats() {
    final seats = <SeatModel>[];
    final columns = ['A', 'B', 'C', 'D', 'E', 'F'];
    final totalRows = 25;
    final random = math.Random(42);

    // Mark some seats as occupied
    for (int i = 0; i < 30; i++) {
      final row = 1 + random.nextInt(totalRows);
      final col = columns[random.nextInt(columns.length)];
      _occupiedSeatIds.add('$row$col');
    }

    for (int row = 1; row <= totalRows; row++) {
      SeatType type;
      if (row <= 2) {
        type = SeatType.first;
      } else if (row <= 5) {
        type = SeatType.business;
      } else if (row <= 8) {
        type = SeatType.premiumEconomy;
      } else if (row == 9 || row == 10) {
        type = SeatType.exitRow;
      } else {
        type = SeatType.economy;
      }

      for (final col in columns) {
        final seatId = '$row$col';
        final status = _occupiedSeatIds.contains(seatId)
            ? SeatStatus.occupied
            : SeatStatus.available;
        seats.add(SeatModel(
          seatId: seatId,
          rowNumber: '$row',
          columnLetter: col,
          seatType: type,
          seatStatus: status,
        ));
      }
    }

    setState(() => _seats = seats);
  }

  void _toggleSeat(SeatModel seat) {
    if (seat.seatStatus == SeatStatus.occupied) return;

    setState(() {
      if (_selectedSeatIds.contains(seat.seatId)) {
        _selectedSeatIds.remove(seat.seatId);
      } else {
        final maxSeats = _criteria.totalPassengers;
        if (_selectedSeatIds.length < maxSeats) {
          _selectedSeatIds.add(seat.seatId);
        }
      }
    });
  }

  Color _seatColor(SeatModel seat) {
    final theme = Theme.of(context);
    switch (seat.seatStatus) {
      case SeatStatus.occupied:
        return theme.colorScheme.outlineVariant.withValues(alpha: 0.3);
      case SeatStatus.selected:
      case SeatStatus.available:
        if (_selectedSeatIds.contains(seat.seatId)) {
          return AppColors.successGreen;
        }
        switch (seat.seatType) {
          case SeatType.first:
            return AppColors.accentMagenta.withValues(alpha: 0.6);
          case SeatType.business:
            return AppColors.accentViolet.withValues(alpha: 0.6);
          case SeatType.premiumEconomy:
            return AppColors.accentCyan.withValues(alpha: 0.6);
          case SeatType.exitRow:
            return AppColors.warningOrange.withValues(alpha: 0.6);
          case SeatType.economy:
            return theme.colorScheme.primary.withValues(alpha: 0.3);
        }
      case SeatStatus.blocked:
        return theme.colorScheme.outlineVariant.withValues(alpha: 0.15);
    }
  }

  bool _canProceed() {
    return _selectedSeatIds.length == _criteria.totalPassengers;
  }

  void _proceedToPassengerInfo() {
    final selectedSeats = _selectedSeatIds.toList();
    final passengers = <PassengerModel>[];
    for (int i = 0; i < _criteria.totalPassengers; i++) {
      passengers.add(PassengerModel());
    }

    final basePrice = 150.0;
    double totalPrice = 0;
    for (final seatId in selectedSeats) {
      final seat = _seats.firstWhere((s) => s.seatId == seatId);
      totalPrice += basePrice * seat.priceMultiplier;
    }

    final booking = TicketBookingModel(
      flightNumber: _flight.flightNumber,
      airlineName: _flight.airlineName,
      departureIata: _flight.depIata,
      arrivalIata: _flight.arrIata,
      departureAirport: _flight.depAirportName,
      arrivalAirport: _flight.arrAirportName,
      departureTime: _flight.scheduledDeparture ?? '',
      arrivalTime: _flight.scheduledArrival ?? '',
      date: _criteria.date.toIso8601String().split('T').first,
      selectedSeats: selectedSeats,
      passengers: passengers,
      basePrice: basePrice,
      totalPrice: totalPrice,
    );

    Get.toNamed(
      AppRoutes.passengerInfo,
      arguments: {'booking': booking, 'criteria': _criteria},
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
        title: const Text('Select Seats'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Text(
              '${_selectedSeatIds.length}/${_criteria.totalPassengers}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
      body: ResponsiveContainer(
        child: Column(
          children: [
            // Flight summary
            FadeSlideIn(
              child: AppSurfaceCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
                      ),
                      child: const Icon(Icons.flight_rounded, size: 23, color: Colors.white),
                    ),
                    const SizedBox(width: AppSpacing.sm + 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _flight.flightNumber,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${_flight.depIata} → ${_flight.arrIata}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_criteria.totalPassengers} seat${_criteria.totalPassengers > 1 ? 's' : ''}',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          'to select',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Legend
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendItem(color: theme.colorScheme.primary.withValues(alpha: 0.3), label: 'Available'),
                  const SizedBox(width: 12),
                  _LegendItem(color: AppColors.successGreen, label: 'Selected'),
                  const SizedBox(width: 12),
                  _LegendItem(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    label: 'Occupied',
                  ),
                ],
              ),
            ),

            // Seat map
            Expanded(
              child: _SeatMap(
                seats: _seats,
                selectedSeatIds: _selectedSeatIds,
                onSeatTap: _toggleSeat,
                seatColor: _seatColor,
              ),
            ),

            // Bottom bar
            AppSurfaceCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Selected seats',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedSeatIds.isEmpty ? 'None' : _selectedSeatIds.join(', '),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    height: AppSpacing.buttonHeight,
                    child: FilledButton.icon(
                      onPressed: _canProceed() ? _proceedToPassengerInfo : null,
                      icon: const Icon(Icons.person_outline_rounded, size: 18),
                      label: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

class _SeatMap extends StatelessWidget {
  const _SeatMap({
    required this.seats,
    required this.selectedSeatIds,
    required this.onSeatTap,
    required this.seatColor,
  });

  final List<SeatModel> seats;
  final Set<String> selectedSeatIds;
  final void Function(SeatModel) onSeatTap;
  final Color Function(SeatModel) seatColor;

  @override
  Widget build(BuildContext context) {
    final rows = <int, List<SeatModel>>{};
    for (final seat in seats) {
      rows.putIfAbsent(int.parse(seat.rowNumber), () => []).add(seat);
    }

    final sortedKeys = rows.keys.toList()..sort();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: sortedKeys.map((rowNum) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '$rowNum',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 6),
                ...rows[rowNum]!.map((seat) {
                  final isSelected = selectedSeatIds.contains(seat.seatId);
                  final isOccupied = seat.seatStatus == SeatStatus.occupied;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: AnimatedPressable(
                      onTap: isOccupied ? null : () => onSeatTap(seat),
                      pressedScale: isOccupied ? 1.0 : 0.9,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: seatColor(seat),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.successGreen
                                : seatColor(seat).withValues(alpha: 0.5),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            seat.columnLetter,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : isOccupied
                                      ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                                      : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 6),
                SizedBox(
                  width: 28,
                  child: Text(
                    '$rowNum',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
