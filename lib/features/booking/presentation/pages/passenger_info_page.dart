import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sky_tracker/app/constants/app_colors.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/routes/app_routes.dart';
import 'package:sky_tracker/core/widgets/animated_widgets.dart';
import 'package:sky_tracker/core/widgets/common_widgets.dart';
import 'package:sky_tracker/core/widgets/responsive_layout.dart';
import 'package:sky_tracker/data/models/booking_model.dart';

class PassengerInfoPage extends StatefulWidget {
  const PassengerInfoPage({super.key});

  @override
  State<PassengerInfoPage> createState() => _PassengerInfoPageState();
}

class _PassengerInfoPageState extends State<PassengerInfoPage> {
  late final TicketBookingModel _booking;
  late final FlightSearchCriteria _criteria;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _booking = args['booking'] as TicketBookingModel;
    _criteria = args['criteria'] as FlightSearchCriteria;
  }

  bool _validateAllPassengers() {
    for (int i = 0; i < _booking.passengers.length; i++) {
      final p = _booking.passengers[i];
      if (!p.isValid) {
        Get.snackbar(
          'Missing Info',
          'Please fill in Passenger ${i + 1} details.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorRed.withValues(alpha: 0.1),
          colorText: AppColors.errorRed,
          margin: const EdgeInsets.all(AppSpacing.sm),
          borderRadius: AppSpacing.radiusMd,
          snackStyle: SnackStyle.FLOATING,
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _confirmBooking() async {
    if (!_validateAllPassengers()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    // Generate booking ID
    _booking = TicketBookingModel(
      bookingId: 'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      flightNumber: _booking.flightNumber,
      airlineName: _booking.airlineName,
      departureIata: _booking.departureIata,
      arrivalIata: _booking.arrivalIata,
      departureAirport: _booking.departureAirport,
      arrivalAirport: _booking.arrivalAirport,
      departureTime: _booking.departureTime,
      arrivalTime: _booking.arrivalTime,
      date: _booking.date,
      selectedSeats: _booking.selectedSeats,
      passengers: _booking.passengers,
      basePrice: _booking.basePrice,
      totalPrice: _booking.totalPrice,
      bookedAt: DateTime.now(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    Get.toNamed(
      AppRoutes.bookingConfirmation,
      arguments: _booking,
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
        title: const Text('Passenger Details'),
      ),
      body: ResponsiveContainer(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              // Flight summary
              SliverToBoxAdapter(
                child: FadeSlideIn(
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
                                _booking.flightNumber,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${_booking.departureIata} → ${_booking.arrivalIata}',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                'Seats: ${_booking.selectedSeats.join(', ')}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Passenger forms
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: SectionHeader(
                    title: 'Passenger Information',
                    actionLabel: '${_booking.passengerCount} passengers',
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final passenger = _booking.passengers[index];
                    final isAdult = index < _criteria.adultCount;
                    final isChild = !isAdult && index < _criteria.adultCount + _criteria.childCount;
                    final label = isAdult
                        ? 'Adult ${index + 1}'
                        : isChild
                            ? 'Child ${index - _criteria.adultCount + 1}'
                            : 'Infant ${index - _criteria.adultCount - _criteria.childCount + 1}';

                    return FadeSlideIn(
                      delay: Duration(milliseconds: 80 * index),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: AppSurfaceCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                    ),
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    label,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  MetaChip(
                                    label: _booking.selectedSeats[index],
                                    color: AppColors.successGreen,
                                    dense: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // First Name
                              TextFormField(
                                initialValue: passenger.firstName,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  prefixIcon: const Icon(Icons.badge_outlined, size: 18),
                                ),
                                textCapitalization: TextCapitalization.words,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                                onChanged: (v) => passenger.firstName = v,
                              ),
                              const SizedBox(height: AppSpacing.sm),

                              // Last Name
                              TextFormField(
                                initialValue: passenger.lastName,
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  prefixIcon: const Icon(Icons.badge_outlined, size: 18),
                                ),
                                textCapitalization: TextCapitalization.words,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                                onChanged: (v) => passenger.lastName = v,
                              ),
                              const SizedBox(height: AppSpacing.sm),

                              // Email (only for first passenger)
                              if (index == 0) ...[
                                TextFormField(
                                  initialValue: passenger.email,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: const Icon(Icons.email_outlined, size: 18),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Required';
                                    if (!v.contains('@')) return 'Invalid email';
                                    return null;
                                  },
                                  onChanged: (v) => passenger.email = v,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],

                              // Phone
                              TextFormField(
                                initialValue: passenger.phone,
                                decoration: InputDecoration(
                                  labelText: 'Phone',
                                  prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                                ),
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
                                ],
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                                onChanged: (v) => passenger.phone = v,
                              ),
                              const SizedBox(height: AppSpacing.sm),

                              // Date of Birth
                              TextFormField(
                                initialValue: passenger.dateOfBirth,
                                decoration: InputDecoration(
                                  labelText: 'Date of Birth',
                                  prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                                ),
                                readOnly: true,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(2000),
                                    firstDate: DateTime(1940),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    passenger.dateOfBirth =
                                        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                    setState(() {});
                                  }
                                },
                              ),
                              const SizedBox(height: AppSpacing.sm),

                              // Gender
                              DropdownButtonFormField<String>(
                                initialValue: passenger.gender,
                                decoration: const InputDecoration(
                                  labelText: 'Gender',
                                  prefixIcon: Icon(Icons.wc_outlined, size: 18),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'male', child: Text('Male')),
                                  DropdownMenuItem(value: 'female', child: Text('Female')),
                                  DropdownMenuItem(value: 'other', child: Text('Other')),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    passenger.gender = v;
                                    setState(() {});
                                  }
                                },
                              ),

                              // Passport (optional)
                              const SizedBox(height: AppSpacing.sm),
                              TextFormField(
                                initialValue: passenger.passportNumber,
                                decoration: const InputDecoration(
                                  labelText: 'Passport Number (optional)',
                                  prefixIcon: Icon(Icons.credit_card_outlined, size: 18),
                                ),
                                textCapitalization: TextCapitalization.characters,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                                ],
                                onChanged: (v) => passenger.passportNumber = v,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _booking.passengers.length,
                ),
              ),

              // Price summary
              SliverToBoxAdapter(
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.lg),
                    child: AppSurfaceCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          _PriceRow(label: 'Base fare', value: '\$${_booking.basePrice.toStringAsFixed(0)}'),
                          const SizedBox(height: 6),
                          _PriceRow(
                            label: 'Seats (${_booking.seatCount})',
                            value: '\$${(_booking.totalPrice - _booking.basePrice).toStringAsFixed(0)}',
                          ),
                          const SizedBox(height: 6),
                          _PriceRow(
                            label: 'Taxes & fees',
                            value: '\$${(_booking.totalPrice * 0.1).toStringAsFixed(0)}',
                          ),
                          const Divider(height: 20),
                          _PriceRow(
                            label: 'Total',
                            value: '\$${(_booking.totalPrice * 1.1).toStringAsFixed(0)}',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Confirm button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: SizedBox(
                    width: double.infinity,
                    height: AppSpacing.buttonHeight,
                    child: AnimatedPressable(
                      onTap: _isLoading ? null : _confirmBooking,
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
                                    Icon(Icons.check_circle_rounded, size: 19, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Confirm Booking',
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
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? null : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: isTotal ? 17 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: isTotal ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
