import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

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

/// Tracks animated position for a flight on the map
class _FlightTrack {
  final FlightModel flight;
  Offset screenPosition;
  late Offset velocity;
  final List<Offset> trail;
  bool isSelected;

  _FlightTrack({
    required this.flight,
    required this.screenPosition,
    this.isSelected = false,
  }) : trail = [screenPosition];

  void updatePosition(Offset newPosition, {bool keepTrail = true}) {
    velocity = newPosition - screenPosition;
    screenPosition = newPosition;
    if (keepTrail) {
      trail.add(newPosition);
      if (trail.length > 30) trail.removeAt(0);
    }
  }

  void animate(double t) {
    if (trail.length >= 2) {
      final last = trail.last;
      final prev = trail[trail.length - 2];
      final dir = last - prev;
      if (dir.distance > 0.01) {
        screenPosition += dir * t * 0.02;
      }
    }
  }
}

class LiveMapPage extends StatefulWidget {
  const LiveMapPage({super.key});

  @override
  State<LiveMapPage> createState() => _LiveMapPageState();
}

class _LiveMapPageState extends State<LiveMapPage>
    with TickerProviderStateMixin {
  final FlightRepository _repository = FlightRepository();
  List<FlightModel> _flights = [];
  List<_FlightTrack> _tracks = [];
  bool _isLoading = true;
  String? _error;
  bool _useMap = true;
  FlightModel? _selectedFlight;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _radarController;
  late AnimationController _trailController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _radarAnimation;

  // Map state
  double _zoom = 1.0;
  Offset _panOffset = Offset.zero;
  final GlobalKey _mapKey = GlobalKey();

  // Timer for live updates
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _trailController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..repeat();
    _pulseAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(_pulseController);
    _radarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_radarController);
    _loadFlights();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _radarController.dispose();
    _trailController.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFlights() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final flights = await _repository.getFlights(limit: 50);
      setState(() {
        _flights = flights.where((f) => f.hasLivePosition).toList();
        _isLoading = false;
        _buildTracks();
      });
      _startLiveUpdates();
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'An unexpected error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  Size get _mapSize {
    final screen = MediaQuery.of(Get.context!).size;
    return Size(screen.width * 3, screen.height * 3);
  }

  void _buildTracks() {
    final size = _mapSize;
    _tracks = _flights.map((f) {
      final pos = _geoToScreen(f.latitude ?? 0, f.longitude ?? 0, size);
      return _FlightTrack(
        flight: f,
        screenPosition: pos,
        isSelected: f.flightId == _selectedFlight?.flightId,
      );
    }).toList();
  }

  void _startLiveUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          // Simulate small position changes for live tracking effect
          for (var track in _tracks) {
            final heading = (track.flight.heading ?? 0) * math.pi / 180;
            final speed = 0.3 + math.Random().nextDouble() * 0.5;
            final dx = math.cos(heading) * speed;
            final dy = -math.sin(heading) * speed;
            final newPos = track.screenPosition + Offset(dx, dy);
            track.updatePosition(newPos);
          }
        });
      }
    });
  }

  Offset _geoToScreen(double lat, double lng, Size size) {
    // Normalize geographic coordinates into the map canvas space.
    final x = ((lng + 180) / 360) * size.width;
    final y = ((90 - lat) / 180) * size.height;
    return Offset(x, y);
  }

  /// Selects the nearest aircraft to a tap inside the map canvas.
  void _handleMapTap(Offset position) {
    _FlightTrack? closest;
    var bestDistance = 34.0;
    for (final track in _tracks) {
      final distance = (track.screenPosition - position).distance;
      if (distance < bestDistance) {
        bestDistance = distance;
        closest = track;
      }
    }

    setState(() {
      _selectedFlight = closest?.flight;
      for (final track in _tracks) {
        track.isSelected = identical(track, closest);
      }
    });
  }

  void _zoomIn() {
    setState(() {
      _zoom = math.min(_zoom * 1.3, 5.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoom = math.max(_zoom / 1.3, 0.3);
    });
  }

  void _resetView() {
    setState(() {
      _zoom = 1.0;
      _panOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.liveMap),
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        actions: [
          SizedBox(
            width: 150,
            child: SegmentedTabs<bool>(
              value: _useMap,
              height: 38,
              onChanged: (value) => setState(() => _useMap = value),
              options: const [
                SegmentOption(
                  value: true,
                  label: 'Map',
                  icon: Icons.map_outlined,
                ),
                SegmentOption(
                  value: false,
                  label: 'List',
                  icon: Icons.format_list_bulleted_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: SkyIconButton(
              icon: Icons.refresh_rounded,
              onPressed: _loadFlights,
              tooltip: 'Refresh',
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.accentPurple,
                ),
              ),
            )
          : _error != null
          ? ErrorStateWidget(message: _error!, onRetry: _loadFlights)
          : _useMap
          ? _buildMapView()
          : _buildListView(),
      bottomSheet: _selectedFlight != null ? _buildFlightTrackingSheet() : null,
    );
  }

  Widget _buildMapView() {
    if (_flights.isEmpty) {
      return const EmptyStateWidget(
        title: 'No Live Positions',
        subtitle: 'No flights with live position data available.',
        icon: Icons.map_outlined,
      );
    }

    return Stack(
      children: [
        // Full-screen interactive map
        InteractiveViewer(
          key: _mapKey,
          panEnabled: true,
          scaleEnabled: true,
          minScale: 0.3,
          maxScale: 5.0,
          onInteractionUpdate: (details) {
            setState(() {
              _zoom = details.scale;
            });
          },
          child: SizedBox(
            width: MediaQuery.of(Get.context!).size.width * 3,
            height: MediaQuery.of(Get.context!).size.height * 3,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) => _handleMapTap(details.localPosition),
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _radarController,
                  _trailController,
                ]),
                builder: (context, child) {
                  return CustomPaint(
                    painter: _FlightRadarMapPainter(
                      tracks: _tracks,
                      selectedFlight: _selectedFlight,
                      radarProgress: _radarAnimation.value,
                      zoom: _zoom,
                      panOffset: _panOffset,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),
        ),

        // Zoom controls
        Positioned(
          right: AppSpacing.md,
          top: MediaQuery.of(Get.context!).size.height / 2 - 30,
          child: Column(
            children: [
              _zoomButton(Icons.add, _zoomIn),
              const SizedBox(height: 8),
              _zoomButton(Icons.remove, _zoomOut),
              const SizedBox(height: 8),
              _zoomButton(Icons.center_focus_strong, _resetView),
            ],
          ),
        ),

        // Top overlay — live flight count
        if (_selectedFlight == null)
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.md,
            child: _GlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PulseDot(color: AppColors.successGreen, size: 6),
                  const SizedBox(width: 6),
                  Text(
                    '${_flights.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'flights live',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Selected flight info overlay
        Positioned(
          top: AppSpacing.sm,
          right: AppSpacing.md,
          child: AnimatedSwitcher(
            duration: AppMotion.normal,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.15, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _selectedFlight == null
                ? const SizedBox(width: 0, height: 0)
                : _buildSelectedFlightOverlay(
                    key: ValueKey(_selectedFlight!.flightId),
                  ),
          ),
        ),

        // Legend
        Positioned(
          bottom: 86,
          left: AppSpacing.md,
          child: _GlassPanel(
            padding: const EdgeInsets.fromLTRB(10, 8, 12, 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LEGEND',
                  style: AppTextStyles.overline.copyWith(
                    fontSize: 8,
                    color: AppColors.accentViolet,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                _legendItem(AppColors.accentPurple, 'Active flight'),
                _legendItem(AppColors.successGreen, 'On time'),
                _legendItem(AppColors.warningOrange, 'Delayed'),
                _legendItem(AppColors.errorRed, 'Cancelled'),
              ],
            ),
          ),
        ),

        // Floating stats bar
        Positioned(
          bottom: AppSpacing.md,
          left: AppSpacing.md,
          right: AppSpacing.md,
          child: _GlassPanel(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 9,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _statChip(
                    Icons.flight_rounded,
                    'Active',
                    '${_flights.length}',
                  ),
                ),
                _statDivider(),
                Expanded(
                  child: _statChip(
                    Icons.radar_rounded,
                    'Feed',
                    'Live',
                    color: AppColors.successGreen,
                  ),
                ),
                _statDivider(),
                Expanded(
                  child: _statChip(
                    Icons.zoom_in_map_rounded,
                    'Zoom',
                    '${_zoom.toStringAsFixed(1)}x',
                  ),
                ),
                _statDivider(),
                Expanded(child: _statChip(Icons.sync_rounded, 'Update', '3s')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onPressed) {
    return AnimatedPressable(
      onTap: onPressed,
      pressedScale: 0.9,
      child: _GlassPanel(
        padding: const EdgeInsets.all(8),
        radius: AppSpacing.radiusSm,
        child: Icon(icon, size: 19, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _statChip(IconData icon, String label, String value, {Color? color}) {
    final tint = color ?? AppColors.accentViolet;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 13, color: tint.withValues(alpha: 0.9)),
        const SizedBox(width: 5),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 8.5,
                color: AppColors.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 10.5,
                color: tint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: Colors.white.withValues(alpha: 0.08),
    );
  }

  Widget _buildSelectedFlightOverlay({Key? key}) {
    final flight = _selectedFlight!;
    return Container(
      key: key,
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.accentPurple.withValues(alpha: 0.45),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                flight.flightNumber,
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.accentPurple,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.successGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            flight.airlineName,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _miniStat('Alt', '${flight.live?.altitude ?? '?'}ft'),
              const SizedBox(width: 8),
              _miniStat(
                'Spd',
                '${flight.live?.groundSpeed ?? flight.live?.speed ?? '?'}kts',
              ),
              const SizedBox(width: 8),
              _miniStat('Hdg', '${flight.heading ?? '?'}°'),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${flight.depIata} → ${flight.arrIata}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 8, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.accentViolet,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFlightTrackingSheet() {
    final flight = _selectedFlight!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 8 + _pulseAnimation.value * 4,
                    height: 8 + _pulseAnimation.value * 4,
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withValues(
                        alpha: _pulseAnimation.value,
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                'LIVE TRACKING',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.successGreen,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Text(
                flight.flightNumber,
                style: AppTextStyles.h4.copyWith(color: AppColors.accentPurple),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _TrackingInfo(
                icon: Icons.airport_shuttle,
                label: 'From',
                value: flight.depIata,
                sub: flight.depAirportName,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _pulseAnimation.value,
                            child: Icon(
                              Icons.flight,
                              size: 20,
                              color: AppColors.accentPurple,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 2),
                      Text(
                        flight.airlineName,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              _TrackingInfo(
                icon: Icons.location_on,
                label: 'To',
                value: flight.arrIata,
                sub: flight.arrAirportName,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _TrackingDetail(
                icon: Icons.my_location,
                label: 'Lat',
                value: '${flight.latitude?.toStringAsFixed(4)}°',
              ),
              _TrackingDetail(
                icon: Icons.location_on,
                label: 'Lng',
                value: '${flight.longitude?.toStringAsFixed(4)}°',
              ),
              _TrackingDetail(
                icon: Icons.compass_calibration,
                label: 'Hdg',
                value: '${flight.heading ?? '?'}°',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _TrackingDetail(
                icon: Icons.vertical_align_top,
                label: 'Alt',
                value: '${flight.live?.altitude ?? '?'}ft',
              ),
              _TrackingDetail(
                icon: Icons.speed,
                label: 'Spd',
                value:
                    '${flight.live?.groundSpeed ?? flight.live?.speed ?? '?'}kts',
              ),
              _TrackingDetail(
                icon: Icons.trending_up,
                label: 'V/S',
                value: '${flight.live?.verticalSpeed ?? '?'}fpm',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Get.toNamed(AppRoutes.flightDetails, arguments: flight);
              },
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text('Full Details'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.accentPurple.withValues(alpha: 0.5),
                ),
                foregroundColor: AppColors.accentPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    if (_flights.isEmpty) {
      return const EmptyStateWidget(
        title: 'No Live Positions',
        subtitle: 'No flights with live position data available.',
        icon: Icons.flight,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFlights,
      color: AppColors.accentPurple,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _flights.length,
        itemBuilder: (context, index) {
          final flight = _flights[index];
          return FadeSlideIn(
            delay: Duration(milliseconds: 45 * (index % 8)),
            child: Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.accentPurple.withValues(
                    alpha: 0.2,
                  ),
                  child: Icon(Icons.flight, color: AppColors.accentPurple),
                ),
                title: Text(
                  flight.flightNumber,
                  style: AppTextStyles.bodyMedium,
                ),
                subtitle: Text(
                  '${flight.depIata} → ${flight.arrIata} • ${flight.airlineName}',
                  style: AppTextStyles.bodySmall,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FlightStatusBadge(status: flight.statusText),
                    const SizedBox(height: 2),
                    Text(
                      'Alt: ${flight.live?.altitude ?? '?'}ft',
                      style: AppTextStyles.caption,
                    ),
                    Text(
                      'Spd: ${flight.live?.groundSpeed ?? '?'}kts',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                onTap: () {
                  setState(() => _selectedFlight = flight);
                  setState(() => _useMap = true);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Translucent, blurred panel used for map overlays.
class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = AppSpacing.radiusMd,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.72),
            borderRadius: borderRadius,
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Custom painter that draws a FlightRadar-style world map with animated airplanes
class _FlightRadarMapPainter extends CustomPainter {
  final List<_FlightTrack> tracks;
  final FlightModel? selectedFlight;
  final double radarProgress;
  final double zoom;
  final Offset panOffset;

  _FlightRadarMapPainter({
    required this.tracks,
    this.selectedFlight,
    required this.radarProgress,
    this.zoom = 1.0,
    this.panOffset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw dark background
    final bgPaint = Paint()..color = AppColors.primaryBackground;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw world grid
    _drawGrid(canvas, size, center);

    // Draw radar rings
    _drawRadarRings(canvas, size, center);

    // Draw radar sweep
    _drawRadarSweep(canvas, size, center);

    // Draw flight paths and airplanes
    for (final track in tracks) {
      _drawFlightTrack(canvas, track);
    }

    // Draw lat/lng labels
    _drawCoordinateLabels(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size, Offset center) {
    final gridPaint = Paint()
      ..color = const Color(0xFF1A1A35).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;

    // Latitude lines (horizontal)
    for (double lat = -80; lat <= 80; lat += 20) {
      final y = center.dy - (lat / 90) * (size.height / 2);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Longitude lines (vertical)
    for (double lng = -180; lng <= 180; lng += 30) {
      final x = center.dx + (lng / 180) * (size.width / 2);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Equator
    final equatorPaint = Paint()
      ..color = const Color(0xFF1A1A35).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      equatorPaint,
    );

    // Prime meridian
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      equatorPaint,
    );
  }

  void _drawRadarRings(Canvas canvas, Size size, Offset center) {
    final maxRadius = math.min(size.width, size.height) / 2 * 0.9;
    final ringPaint = Paint()
      ..color = AppColors.accentPurple.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 1; i <= 6; i++) {
      final radius = maxRadius * (i / 6);
      canvas.drawCircle(center, radius, ringPaint);
    }
  }

  void _drawRadarSweep(Canvas canvas, Size size, Offset center) {
    final maxRadius = math.min(size.width, size.height) / 2 * 0.9;
    final sweepAngle = radarProgress * 2 * math.pi;

    // Draw radar sweep cone using path
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(sweepAngle - math.pi / 2);
    canvas.translate(-center.dx, -center.dy);

    final sweepPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: maxRadius),
        -math.pi / 2,
        math.pi / 6,
        false,
      )
      ..close();

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + math.pi / 6,
        colors: [
          AppColors.accentPurple.withValues(alpha: 0.2),
          AppColors.accentPurple.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    canvas.drawPath(sweepPath, sweepPaint);
    canvas.restore();

    // Sweep line
    final sweepLinePaint = Paint()
      ..color = AppColors.accentPurple.withValues(alpha: 0.5)
      ..strokeWidth = 1.5;
    final sweepEnd = Offset(
      center.dx + maxRadius * math.cos(sweepAngle - math.pi / 2),
      center.dy + maxRadius * math.sin(sweepAngle - math.pi / 2),
    );
    canvas.drawLine(center, sweepEnd, sweepLinePaint);

    // Center dot
    final centerDotPaint = Paint()
      ..color = AppColors.accentPurple
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3, centerDotPaint);
  }

  void _drawFlightTrack(Canvas canvas, _FlightTrack track) {
    final isSelected = track.flight.flightId == selectedFlight?.flightId;
    final pos = track.screenPosition;

    // Draw flight trail path
    if (track.trail.length > 1) {
      final trailPaint = Paint()
        ..color = isSelected
            ? AppColors.accentPurple.withValues(alpha: 0.4)
            : AppColors.accentViolet.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2 : 1;

      final trailPath = Path()
        ..moveTo(track.trail.first.dx, track.trail.first.dy);
      for (int i = 1; i < track.trail.length; i++) {
        trailPath.lineTo(track.trail[i].dx, track.trail[i].dy);
      }
      canvas.drawPath(trailPath, trailPaint);
    }

    // Draw pulse ring for selected flight
    if (isSelected) {
      // Outer pulse
      final outerPulsePaint = Paint()
        ..color = AppColors.accentPurple.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(pos, 35, outerPulsePaint);

      // Inner pulse
      final innerPulsePaint = Paint()
        ..color = AppColors.accentPurple.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(pos, 22, innerPulsePaint);

      // Glow effect
      final glowPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            AppColors.accentPurple.withValues(alpha: 0.3),
            AppColors.accentPurple.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: pos, radius: 40));
      canvas.drawCircle(pos, 40, glowPaint);
    }

    // Draw airplane icon with heading rotation
    final heading = (track.flight.heading ?? 0) * math.pi / 180;
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(
      -heading + math.pi / 2,
    ); // Adjust for canvas coordinate system

    // Airplane body - detailed shape
    final planeColor = isSelected
        ? AppColors.accentPurple
        : AppColors.accentViolet;
    final planePaint = Paint()
      ..color = planeColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    // Fuselage
    final fuselage = Path();
    fuselage.moveTo(10, 0); // Nose
    fuselage.lineTo(4, -1.5);
    fuselage.lineTo(-6, -1.5);
    fuselage.lineTo(-10, -2);
    fuselage.lineTo(-10, 2);
    fuselage.lineTo(-6, 1.5);
    fuselage.lineTo(4, 1.5);
    fuselage.close();
    canvas.drawPath(fuselage, planePaint);

    // Wings
    final wingPaint = Paint()
      ..color = planeColor
      ..style = PaintingStyle.fill;

    // Left wing
    final leftWing = Path();
    leftWing.moveTo(-2, -1.5);
    leftWing.lineTo(-6, -8);
    leftWing.lineTo(-4, -8);
    leftWing.lineTo(0, -1.5);
    leftWing.close();
    canvas.drawPath(leftWing, wingPaint);

    // Right wing
    final rightWing = Path();
    rightWing.moveTo(-2, 1.5);
    rightWing.lineTo(-6, 8);
    rightWing.lineTo(-4, 8);
    rightWing.lineTo(0, 1.5);
    rightWing.close();
    canvas.drawPath(rightWing, wingPaint);

    // Tail
    final tailPaint = Paint()
      ..color = planeColor
      ..style = PaintingStyle.fill;

    final tail = Path();
    tail.moveTo(-8, -1.5);
    tail.lineTo(-12, -5);
    tail.lineTo(-10, -5);
    tail.lineTo(-7, -1.5);
    tail.close();
    canvas.drawPath(tail, tailPaint);

    canvas.restore();

    // Draw flight number label
    final labelColor = isSelected
        ? AppColors.accentPurple
        : AppColors.textSecondary;
    final labelSize = isSelected ? 11.0 : 9.0;
    final fontWeight = isSelected ? FontWeight.bold : FontWeight.w500;

    final textPainter = TextPainter(
      text: TextSpan(
        text: track.flight.flightNumber,
        style: TextStyle(
          fontSize: labelSize,
          color: labelColor,
          fontWeight: fontWeight,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Background for label
    final labelBgPaint = Paint()
      ..color = AppColors.cardBackground.withValues(alpha: 0.8);
    final labelRect = Rect.fromLTWH(
      pos.dx + 14,
      pos.dy - 12,
      textPainter.width + 6,
      textPainter.height + 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(3)),
      labelBgPaint,
    );

    // Label border for selected
    if (isSelected) {
      final labelBorderPaint = Paint()
        ..color = AppColors.accentPurple.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(3)),
        labelBorderPaint,
      );
    }

    textPainter.paint(canvas, Offset(pos.dx + 17, pos.dy - 10));

    // Draw altitude/speed badge for selected flight
    if (isSelected) {
      _drawInfoBadge(
        canvas,
        pos.dx + 14,
        pos.dy + 8,
        'Alt: ${track.flight.live?.altitude ?? '?'}ft',
      );
      _drawInfoBadge(
        canvas,
        pos.dx + 14,
        pos.dy + 22,
        'Spd: ${track.flight.live?.groundSpeed ?? track.flight.live?.speed ?? '?'}kts',
      );
    }
  }

  void _drawInfoBadge(Canvas canvas, double x, double y, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 9,
          color: AppColors.accentViolet,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final bgPaint = Paint()
      ..color = AppColors.cardBackground.withValues(alpha: 0.85);
    final rect = Rect.fromLTWH(
      x,
      y,
      textPainter.width + 6,
      textPainter.height + 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      bgPaint,
    );
    textPainter.paint(canvas, Offset(x + 3, y + 2));
  }

  void _drawCoordinateLabels(Canvas canvas, Size size) {
    final labelPaint = TextPainter(
      text: const TextSpan(
        text: '0°',
        style: TextStyle(fontSize: 8, color: Color(0xFF4A4A6A)),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPaint.layout();

    // Equator label
    labelPaint.paint(canvas, Offset(size.width / 2 + 4, size.height / 2 - 10));

    // Prime meridian label
    final meridianLabel = TextPainter(
      text: const TextSpan(
        text: '0°',
        style: TextStyle(fontSize: 8, color: Color(0xFF4A4A6A)),
      ),
      textDirection: TextDirection.ltr,
    );
    meridianLabel.layout();
    meridianLabel.paint(canvas, Offset(size.width / 2 + 4, 4));
  }

  @override
  bool shouldRepaint(covariant _FlightRadarMapPainter oldDelegate) {
    return oldDelegate.radarProgress != radarProgress ||
        oldDelegate.selectedFlight != selectedFlight ||
        oldDelegate.zoom != zoom ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.tracks.length != tracks.length;
  }
}

class _TrackingInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;

  const _TrackingInfo({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.accentPurple),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          sub,
          style: AppTextStyles.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _TrackingDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TrackingDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.accentPurple.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 3),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
