import 'package:flutter/material.dart';
import 'package:sky_tracker/app/constants/app_colors.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/constants/app_text_styles.dart';
import 'package:sky_tracker/core/widgets/animated_widgets.dart';
import 'package:sky_tracker/core/widgets/common_widgets.dart';
import 'package:sky_tracker/data/models/flight_model.dart';

/// Color for a flight status label.
Color flightStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'active':
    case 'in air':
    case 'en-route':
      return AppColors.successGreen;
    case 'landed':
      return AppColors.infoBlue;
    case 'delayed':
      return AppColors.warningOrange;
    case 'cancelled':
    case 'canceled':
      return AppColors.errorRed;
    default:
      return AppColors.textMuted;
  }
}

/// Professional summary card for a single flight.
class FlightCard extends StatelessWidget {
  const FlightCard({super.key, required this.flight, this.onTap});

  final FlightModel flight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = flightStatusColor(flight.statusText);
    final gate = flight.depGate;
    final terminal = flight.depTerminal;

    return AppSurfaceCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm + 2,
      ),
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
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.22),
                  ),
                ),
                child: Icon(
                  Icons.flight_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
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
                        fontFeatures: AppTextStyles.tabular,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
              FlightStatusBadge(status: flight.statusText),
            ],
          ),
          const SizedBox(height: AppSpacing.md + 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _AirportBlock(
                  code: flight.depIata,
                  name: flight.depAirportName,
                  time: _shortTime(flight.scheduledDeparture),
                  alignEnd: false,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 86,
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    AnimatedFlightPath(
                      color: statusColor,
                      height: 18,
                      planeSize: 13,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _durationLabel(
                        flight.scheduledDeparture,
                        flight.scheduledArrival,
                      ),
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
                child: _AirportBlock(
                  code: flight.arrIata,
                  name: flight.arrAirportName,
                  time: _shortTime(flight.scheduledArrival),
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (terminal != null && terminal.isNotEmpty) ...[
                MetaChip(
                  label: 'Terminal $terminal',
                  icon: Icons.apartment_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  dense: true,
                ),
                const SizedBox(width: 6),
              ],
              if (gate != null && gate.isNotEmpty)
                MetaChip(
                  label: 'Gate $gate',
                  icon: Icons.door_front_door_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                  dense: true,
                ),
              if ((terminal == null || terminal.isEmpty) &&
                  (gate == null || gate.isEmpty))
                MetaChip(
                  label: _dateLabel(flight.scheduledDeparture),
                  icon: Icons.event_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                  dense: true,
                ),
              const Spacer(),
              Text(
                'Details',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AirportBlock extends StatelessWidget {
  const _AirportBlock({
    required this.code,
    required this.name,
    required this.time,
    required this.alignEnd,
  });

  final String code;
  final String name;
  final String time;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          code.isNotEmpty ? code : '—',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            fontFeatures: AppTextStyles.tabular,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          name,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
            fontFeatures: AppTextStyles.tabular,
          ),
        ),
      ],
    );
  }
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
  if (raw == null || raw.isEmpty) return 'Scheduled';
  try {
    return raw.split(' ').first;
  } catch (_) {
    return 'Scheduled';
  }
}

String _durationLabel(String? departure, String? arrival) {
  if (departure == null || arrival == null) return 'scheduled';
  try {
    final dep = DateTime.tryParse(departure.replaceFirst(' ', 'T'));
    final arr = DateTime.tryParse(arrival.replaceFirst(' ', 'T'));
    if (dep == null || arr == null) return 'scheduled';
    final minutes = arr.difference(dep).inMinutes.abs();
    if (minutes == 0) return 'scheduled';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  } catch (_) {
    return 'scheduled';
  }
}

/// Tinted status pill with a live dot for active flights.
class FlightStatusBadge extends StatelessWidget {
  const FlightStatusBadge({
    super.key,
    required this.status,
    this.showDot = true,
  });

  final String status;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final color = flightStatusColor(status);
    final isLive =
        status.toLowerCase() == 'active' ||
        status.toLowerCase() == 'in air' ||
        status.toLowerCase() == 'en-route';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            if (isLive)
              PulseDot(color: color, size: 5, pulseScale: 2.6)
            else
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            const SizedBox(width: 6),
          ],
          Text(
            status.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
