import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sky_tracker/app/constants/app_colors.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/constants/app_strings.dart';
import 'package:sky_tracker/app/constants/app_text_styles.dart';
import 'package:sky_tracker/app/routes/app_routes.dart';
import 'package:sky_tracker/core/services/favorites_service.dart';
import 'package:sky_tracker/core/widgets/animated_widgets.dart';
import 'package:sky_tracker/core/widgets/common_widgets.dart';
import 'package:sky_tracker/core/widgets/flight_card.dart';
import 'package:sky_tracker/data/models/flight_model.dart';

class FlightDetailsPage extends StatefulWidget {
  const FlightDetailsPage({super.key});

  @override
  State<FlightDetailsPage> createState() => _FlightDetailsPageState();
}

class _FlightDetailsPageState extends State<FlightDetailsPage> {
  late final FlightModel _flight;
  late final FavoritesService _favoritesService;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    _flight = args is FlightModel ? args : FlightModel();
    _favoritesService = Get.find<FavoritesService>();
    _isFavorite = _favoritesService.isFavorite(_flight.flightId ?? '');
  }

  void _toggleFavorite() {
    final id = _flight.flightId ?? '';
    if (id.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _isFavorite = !_isFavorite;
    });
    _favoritesService.toggleFavorite(id);
    Get.showSnackbar(
      GetSnackBar(
        message: _isFavorite
            ? '${_flight.flightNumber} saved to favorites'
            : '${_flight.flightNumber} removed from favorites',
        duration: const Duration(milliseconds: 1600),
        margin: const EdgeInsets.all(AppSpacing.md),
        backgroundColor:
            Theme.of(context).cardTheme.color ?? AppColors.cardBackground,
        borderRadius: AppSpacing.radiusMd,
        icon: Icon(
          _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: _isFavorite ? AppColors.accentMagenta : AppColors.textMuted,
        ),
        snackStyle: SnackStyle.FLOATING,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = flightStatusColor(_flight.statusText);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        title: const Text(AppStrings.flightDetails),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: AnimatedPressable(
              onTap: _toggleFavorite,
              pressedScale: 0.88,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _isFavorite
                      ? AppColors.accentMagenta.withValues(alpha: 0.14)
                      : theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.6,
                        ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: _isFavorite
                        ? AppColors.accentMagenta.withValues(alpha: 0.35)
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: AppMotion.normal,
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutBack,
                      ),
                      child: child,
                    );
                  },
                  child: Icon(
                    _isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    key: ValueKey(_isFavorite),
                    size: 20,
                    color: _isFavorite
                        ? AppColors.accentMagenta
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.xs,
          AppSpacing.gutter,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideIn(
              child: AppSurfaceCard(
                onTap: null,
                glow: true,
                padding: const EdgeInsets.all(AppSpacing.md + 2),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.16),
                    theme.colorScheme.secondary.withValues(alpha: 0.07),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm + 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.flight_rounded,
                            size: 23,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm + 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _flight.flightNumber,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                  fontFeatures: AppTextStyles.tabular,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                _flight.airlineName,
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        FlightStatusBadge(status: _flight.statusText),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _Endpoint(
                            code: _flight.depIata,
                            name: _flight.depAirportName,
                            time: _formatTime(_flight.scheduledDeparture),
                            date: _formatDate(_flight.scheduledDeparture),
                            alignEnd: false,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SizedBox(
                          width: 80,
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              AnimatedFlightPath(
                                color: statusColor,
                                height: 20,
                                planeSize: 14,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _duration(
                                  _flight.scheduledDeparture,
                                  _flight.scheduledArrival,
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _Endpoint(
                            code: _flight.arrIata,
                            name: _flight.arrAirportName,
                            time: _formatTime(_flight.scheduledArrival),
                            date: _formatDate(_flight.scheduledArrival),
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Divider(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.08,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm + 2),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (_flight.aircraftModel != null &&
                            _flight.aircraftModel!.isNotEmpty)
                          MetaChip(
                            label: _flight.aircraftModel!,
                            icon: Icons.airplanemode_active_rounded,
                            color: theme.colorScheme.primary,
                            dense: true,
                          ),
                        if (_flight.aircraftRegistration != null &&
                            _flight.aircraftRegistration!.isNotEmpty)
                          MetaChip(
                            label: _flight.aircraftRegistration!,
                            icon: Icons.confirmation_number_outlined,
                            color: theme.colorScheme.onSurfaceVariant,
                            dense: true,
                          ),
                        if (_flight.hasLivePosition)
                          MetaChip(
                            label: 'Live position',
                            icon: Icons.radar_rounded,
                            color: AppColors.successGreen,
                            dense: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            FadeSlideIn(
              delay: const Duration(milliseconds: 80),
              child: _SectionCard(
                title: AppStrings.departure,
                subtitle: _flight.depAirportName,
                icon: Icons.flight_takeoff_rounded,
                accent: AppColors.accentViolet,
                rows: [
                  _Detail(
                    icon: Icons.tag_rounded,
                    label: 'IATA',
                    value: _flight.depIata,
                  ),
                  _Detail(
                    icon: Icons.schedule_rounded,
                    label: 'Scheduled',
                    value: _formatTime(_flight.scheduledDeparture),
                  ),
                  _Detail(
                    icon: Icons.timer_outlined,
                    label: 'Estimated',
                    value: _formatTime(_flight.estimatedDeparture),
                  ),
                  _Detail(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Actual',
                    value: _formatTime(_flight.actualDeparture),
                  ),
                  _Detail(
                    icon: Icons.location_city_rounded,
                    label: 'Terminal',
                    value: _flight.depTerminal,
                  ),
                  _Detail(
                    icon: Icons.door_front_door_outlined,
                    label: 'Gate',
                    value: _flight.depGate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm + 4),

            FadeSlideIn(
              delay: const Duration(milliseconds: 130),
              child: _SectionCard(
                title: AppStrings.arrival,
                subtitle: _flight.arrAirportName,
                icon: Icons.flight_land_rounded,
                accent: AppColors.accentCyan,
                rows: [
                  _Detail(
                    icon: Icons.tag_rounded,
                    label: 'IATA',
                    value: _flight.arrIata,
                  ),
                  _Detail(
                    icon: Icons.schedule_rounded,
                    label: 'Scheduled',
                    value: _formatTime(_flight.scheduledArrival),
                  ),
                  _Detail(
                    icon: Icons.timer_outlined,
                    label: 'Estimated',
                    value: _formatTime(_flight.estimatedArrival),
                  ),
                  _Detail(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Actual',
                    value: _formatTime(_flight.actualArrival),
                  ),
                  _Detail(
                    icon: Icons.location_city_rounded,
                    label: 'Terminal',
                    value: _flight.arrTerminal,
                  ),
                  _Detail(
                    icon: Icons.door_front_door_outlined,
                    label: 'Gate',
                    value: _flight.arrGate,
                  ),
                ],
              ),
            ),
            if (_flight.aircraftModel != null ||
                _flight.aircraftRegistration != null) ...[
              const SizedBox(height: AppSpacing.sm + 4),
              FadeSlideIn(
                delay: const Duration(milliseconds: 180),
                child: _SectionCard(
                  title: AppStrings.aircraft,
                  icon: Icons.airplanemode_active_rounded,
                  accent: AppColors.warningOrange,
                  rows: [
                    _Detail(
                      icon: Icons.airplanemode_active_rounded,
                      label: 'Model',
                      value: _flight.aircraftModel,
                    ),
                    _Detail(
                      icon: Icons.confirmation_number_outlined,
                      label: 'Registration',
                      value: _flight.aircraftRegistration,
                    ),
                  ],
                ),
              ),
            ],
            if (_flight.hasLivePosition) ...[
              const SizedBox(height: AppSpacing.sm + 4),
              FadeSlideIn(
                delay: const Duration(milliseconds: 230),
                child: _SectionCard(
                  title: 'Live Position',
                  subtitle: 'Updated moments ago',
                  icon: Icons.radar_rounded,
                  accent: AppColors.successGreen,
                  trailing: PulseDot(color: AppColors.successGreen, size: 6),
                  rows: [
                    _Detail(
                      icon: Icons.my_location_rounded,
                      label: 'Latitude',
                      value: _flight.latitude?.toStringAsFixed(4),
                    ),
                    _Detail(
                      icon: Icons.location_on_outlined,
                      label: 'Longitude',
                      value: _flight.longitude?.toStringAsFixed(4),
                    ),
                    _Detail(
                      icon: Icons.compass_calibration_rounded,
                      label: 'Heading',
                      value: _flight.heading == null
                          ? null
                          : '${_flight.heading}°',
                      trailing: _flight.heading == null
                          ? null
                          : Transform.rotate(
                              angle: (_flight.heading! * math.pi) / 180,
                              child: const Icon(
                                Icons.navigation_rounded,
                                size: 15,
                                color: AppColors.successGreen,
                              ),
                            ),
                    ),
                    _Detail(
                      icon: Icons.vertical_align_top_rounded,
                      label: 'Altitude',
                      value: _flight.live?.altitude == null
                          ? null
                          : '${_flight.live!.altitude} ft',
                    ),
                    _Detail(
                      icon: Icons.speed_rounded,
                      label: 'Ground speed',
                      value: _flight.live?.groundSpeed == null
                          ? null
                          : '${_flight.live!.groundSpeed} kts',
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            FadeSlideIn(
              delay: const Duration(milliseconds: 280),
              child: SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: FilledButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.liveMap),
                  icon: const Icon(Icons.public_rounded, size: 19),
                  label: const Text('Track on live map'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '—';
    try {
      final parts = time.split(' ');
      if (parts.length >= 2) {
        final timePart = parts[1].split(':');
        if (timePart.length >= 2) return '${timePart[0]}:${timePart[1]}';
      }
      return time;
    } catch (_) {
      return time;
    }
  }

  String _formatDate(String? time) {
    if (time == null || time.isEmpty) return '';
    try {
      final parsed = DateTime.tryParse(time.replaceFirst(' ', 'T'));
      if (parsed == null) return time.split(' ').first;
      return DateFormat('d MMM').format(parsed);
    } catch (_) {
      return '';
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
}

class _Endpoint extends StatelessWidget {
  const _Endpoint({
    required this.code,
    required this.name,
    required this.time,
    required this.date,
    required this.alignEnd,
  });

  final String code;
  final String name;
  final String time;
  final String date;
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
            fontSize: 27,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            height: 1.05,
            fontFeatures: AppTextStyles.tabular,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          name,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.5),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
        ),
        const SizedBox(height: 6),
        Text(
          time,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFeatures: AppTextStyles.tabular,
          ),
        ),
        if (date.isNotEmpty)
          Text(date, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
      ],
    );
  }
}

class _Detail {
  const _Detail({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.rows,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accent;
  final List<_Detail> rows;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleRows = rows
        .where((row) => row.value != null && row.value!.trim().isNotEmpty)
        .toList();

    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm + 2,
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: accent.withValues(alpha: 0.24)),
                  ),
                  child: Icon(icon, size: 17, color: accent),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          if (visibleRows.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'No data available',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
                  ),
                ],
              ),
            )
          else
            ...List.generate(visibleRows.length, (index) {
              final row = visibleRows[index];
              return Column(
                children: [
                  if (index > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.md + 46),
                      child: Divider(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  _DetailRow(detail: row),
                ],
              );
            }),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.detail});

  final _Detail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      child: Row(
        children: [
          Icon(
            detail.icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          SizedBox(
            width: 96,
            child: Text(
              detail.label,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (detail.trailing != null) ...[
                  detail.trailing!,
                  const SizedBox(width: 5),
                ],
                Flexible(
                  child: Text(
                    detail.value ?? '—',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFeatures: AppTextStyles.tabular,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
