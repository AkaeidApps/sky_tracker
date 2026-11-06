import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sky_tracker/app/constants/app_colors.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/constants/app_text_styles.dart';
import 'package:sky_tracker/core/widgets/animated_widgets.dart';
import 'package:sky_tracker/core/widgets/common_widgets.dart';
import 'package:sky_tracker/core/widgets/responsive_layout.dart';
import 'package:sky_tracker/data/models/booking_model.dart';

class BookingConfirmationPage extends StatefulWidget {
  const BookingConfirmationPage({super.key});

  @override
  State<BookingConfirmationPage> createState() => _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage>
    with SingleTickerProviderStateMixin {
  late final TicketBookingModel _booking;
  late final AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _booking = Get.arguments as TicketBookingModel;
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _celebrationController.forward();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

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

  String _dateLabel(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final parsed = DateTime.tryParse(raw.replaceFirst(' ', 'T'));
      if (parsed == null) return raw.split(' ').first;
      return DateFormat('d MMM yyyy').format(parsed);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: ResponsiveContainer(
        child: CustomScrollView(
          slivers: [
            // Celebration header
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.md),
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _celebrationController,
                          curve: Curves.easeOutBack,
                        ),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.successGreen.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            size: 44,
                            color: AppColors.successGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          'Booking Confirmed!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 300),
                        child: Text(
                          'Your flight has been booked successfully.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Booking code
            SliverToBoxAdapter(
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 400),
                child: AppSurfaceCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  glow: true,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Icon(
                              Icons.confirmation_number_rounded,
                              size: 18,
                              color: AppColors.successGreen,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Booking Code',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _booking.bookingCode,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2,
                                    fontFeatures: AppTextStyles.tabular,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedPressable(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: _booking.bookingCode));
                              Get.snackbar(
                                'Copied',
                                'Booking code copied to clipboard',
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 2),
                                margin: const EdgeInsets.all(AppSpacing.sm),
                                borderRadius: AppSpacing.radiusMd,
                                snackStyle: SnackStyle.FLOATING,
                              );
                            },
                            pressedScale: 0.9,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.copy_rounded,
                                    size: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Copy',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // E-Ticket
            SliverToBoxAdapter(
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 500),
                child: _ETicket(
                  booking: _booking,
                  shortTime: _shortTime,
                  dateLabel: _dateLabel,
                ),
              ),
            ),

            // Flight route
            SliverToBoxAdapter(
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 600),
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
                  child: SectionHeader(title: 'Flight Details'),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 650),
                child: AppSurfaceCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: AppColors.brandGradient,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
                            ),
                            child: const Icon(
                              Icons.flight_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
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
                                  _booking.airlineName,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _booking.departureIata,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  _booking.departureAirport,
                                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _shortTime(_booking.departureTime),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _dateLabel(_booking.departureTime),
                                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SizedBox(
                            width: 80,
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                AnimatedFlightPath(
                                  color: AppColors.successGreen,
                                  height: 20,
                                  planeSize: 14,
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
                                  _booking.arrivalIata,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  _booking.arrivalAirport,
                                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _shortTime(_booking.arrivalTime),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _dateLabel(_booking.arrivalTime),
                                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Passengers
            SliverToBoxAdapter(
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 700),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: SectionHeader(
                    title: 'Passengers',
                    actionLabel: '${_booking.passengerCount}',
                  ),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final passenger = _booking.passengers[index];
                  return FadeSlideIn(
                    delay: Duration(milliseconds: 750 + 50 * index),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AppSurfaceCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    passenger.fullName,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Seat ${_booking.selectedSeats[index]}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            MetaChip(
                              label: _booking.selectedSeats[index],
                              color: AppColors.successGreen,
                              dense: true,
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

            // Actions
            SliverToBoxAdapter(
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 900),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: AppSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: AppSpacing.buttonHeight,
                        child: FilledButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Get.back();
                            Get.back();
                            Get.back();
                          },
                          icon: const Icon(Icons.home_rounded, size: 18),
                          label: const Text('Back to Home'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton.icon(
                        onPressed: () {
                          // Share booking
                          Get.snackbar(
                            'Share',
                            'Booking details can be shared via email',
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
                            margin: const EdgeInsets.all(AppSpacing.sm),
                            borderRadius: AppSpacing.radiusMd,
                            snackStyle: SnackStyle.FLOATING,
                          );
                        },
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: const Text('Share booking'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// E-Ticket card with dashed border
class _ETicket extends StatelessWidget {
  const _ETicket({
    required this.booking,
    required this.shortTime,
    required this.dateLabel,
  });

  final TicketBookingModel booking;
  final String Function(String?) shortTime;
  final String Function(String?) dateLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'E-TICKET',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        booking.bookingCode,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.departureIata,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 28,
                              ),
                            ),
                            Text(
                              shortTime(booking.departureTime),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              booking.arrivalIata,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 28,
                              ),
                            ),
                            Text(
                              shortTime(booking.arrivalTime),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Divider(color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        'Flight',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        booking.flightNumber,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Date',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        booking.date,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Dashed cut line
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: CustomPaint(
                painter: _TicketCutLinePainter(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketCutLinePainter extends CustomPainter {
  _TicketCutLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Left notch
    canvas.drawCircle(
      Offset(0, size.height * 0.75),
      8,
      paint,
    );
    // Right notch
    canvas.drawCircle(
      Offset(size.width, size.height * 0.75),
      8,
      paint,
    );

    // Dashed line
    final y = size.height * 0.75;
    for (double x = 12; x < size.width - 12; x += 8) {
      canvas.drawLine(Offset(x, y), Offset(x + 4, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TicketCutLinePainter oldDelegate) => false;
}
