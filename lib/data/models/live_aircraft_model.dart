import 'dart:math' as math;

/// One live aircraft state vector from the OpenSky Network.
class LiveAircraft {
  const LiveAircraft({
    required this.icao24,
    required this.callsign,
    required this.originCountry,
    this.longitude,
    this.latitude,
    this.baroAltitude,
    this.geoAltitude,
    this.onGround = false,
    this.velocity,
    this.trueTrack,
    this.verticalRate,
    this.squawk,
    this.lastContact,
  });

  final String icao24;
  final String? callsign;
  final String originCountry;
  final double? longitude;
  final double? latitude;
  final double? baroAltitude;
  final double? geoAltitude;
  final bool onGround;

  /// Ground speed in m/s.
  final double? velocity;

  /// Track angle in degrees clockwise from north.
  final double? trueTrack;

  /// Vertical rate in m/s.
  final double? verticalRate;
  final String? squawk;
  final DateTime? lastContact;

  bool get hasPosition => latitude != null && longitude != null;

  String get displayCallsign {
    final value = callsign?.trim();
    if (value == null || value.isEmpty) return icao24.toUpperCase();
    return value;
  }

  double? get altitudeFt {
    final meters = baroAltitude ?? geoAltitude;
    return meters == null ? null : meters * 3.28084;
  }

  double? get speedKts =>
      velocity == null ? null : velocity! * 1.9438444924406;

  double? get verticalRateFpm =>
      verticalRate == null ? null : verticalRate! * 196.85039370079;

  /// `up`, `down` or `level`.
  String get verticalTrend {
    final rate = verticalRate;
    if (rate == null || rate.abs() < 0.5) return 'level';
    return rate > 0 ? 'up' : 'down';
  }

  double distanceKmTo(double lat, double lng) {
    final aircraftLat = latitude;
    final aircraftLng = longitude;
    if (aircraftLat == null || aircraftLng == null) return double.infinity;
    const earthRadiusKm = 6371.0;
    final dLat = _radians(lat - aircraftLat);
    final dLng = _radians(lng - aircraftLng);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_radians(aircraftLat)) *
            math.cos(_radians(lat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  /// Parses an OpenSky `states` row.
  ///
  /// Index layout: icao24, callsign, origin_country, time_position,
  /// last_contact, longitude, latitude, baro_altitude, on_ground, velocity,
  /// true_track, vertical_rate, sensors, geo_altitude, squawk, spi, ...
  factory LiveAircraft.fromStateList(List<dynamic> row) {
    final icao24 = row.isNotEmpty ? (row[0]?.toString() ?? '') : '';
    final lastContactSeconds = _toInt(row.length > 4 ? row[4] : null);

    return LiveAircraft(
      icao24: icao24.isEmpty ? 'unknown' : icao24,
      callsign: row.length > 1 ? row[1]?.toString() : null,
      originCountry: row.length > 2 ? (row[2]?.toString() ?? 'Unknown') : 'Unknown',
      longitude: _toDouble(row.length > 5 ? row[5] : null),
      latitude: _toDouble(row.length > 6 ? row[6] : null),
      baroAltitude: _toDouble(row.length > 7 ? row[7] : null),
      onGround: row.length > 8 && row[8] == true,
      velocity: _toDouble(row.length > 9 ? row[9] : null),
      trueTrack: _toDouble(row.length > 10 ? row[10] : null),
      verticalRate: _toDouble(row.length > 11 ? row[11] : null),
      geoAltitude: _toDouble(row.length > 13 ? row[13] : null),
      squawk: row.length > 14 ? row[14]?.toString() : null,
      lastContact: lastContactSeconds == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastContactSeconds * 1000),
    );
  }
}

/// A global or regional snapshot of live aircraft.
class LiveSnapshot {
  const LiveSnapshot({required this.aircraft, this.timestamp});

  final List<LiveAircraft> aircraft;
  final DateTime? timestamp;
}

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int? _toInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double _radians(double degrees) => degrees * math.pi / 180;
