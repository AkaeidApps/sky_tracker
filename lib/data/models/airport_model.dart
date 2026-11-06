import 'dart:math' as math;

/// A single airport from the bundled worldwide dataset.
class AirportModel {
  const AirportModel({
    required this.icao,
    required this.iata,
    required this.name,
    required this.city,
    required this.countryCode,
    required this.countryName,
    required this.latitude,
    required this.longitude,
    required this.elevationFt,
    required this.timezone,
  });

  final String icao;
  final String iata;
  final String name;
  final String city;
  final String countryCode;
  final String countryName;
  final double latitude;
  final double longitude;
  final int elevationFt;
  final String timezone;

  bool get hasIata => iata.isNotEmpty;

  String get displayCode => hasIata ? iata : icao;

  String get title => name.isEmpty ? displayCode : name;

  String get locationLabel {
    final parts = [
      if (city.isNotEmpty) city,
      if (countryName.isNotEmpty) countryName,
    ];
    return parts.join(', ');
  }

  String get elevationLabel {
    final meters = (elevationFt * 0.3048).round();
    return '$elevationFt ft · $meters m';
  }

  String get coordinatesLabel =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  /// Distance in kilometres from this airport to a point.
  double distanceKmTo(double lat, double lng) {
    const earthRadiusKm = 6371.0;
    final dLat = _radians(lat - latitude);
    final dLng = _radians(lng - longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_radians(latitude)) *
            math.cos(_radians(lat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  /// Parses the compact array layout used by `assets/data/airports.json`.
  factory AirportModel.fromCompactList(
    List<dynamic> row, {
    required Map<String, String> countries,
  }) {
    final countryCode = row[4]?.toString() ?? '';
    return AirportModel(
      icao: row[0]?.toString() ?? '',
      iata: row[1]?.toString() ?? '',
      name: row[2]?.toString() ?? '',
      city: row[3]?.toString() ?? '',
      countryCode: countryCode,
      countryName: countries[countryCode] ?? countryCode,
      latitude: (row[5] as num?)?.toDouble() ?? 0,
      longitude: (row[6] as num?)?.toDouble() ?? 0,
      elevationFt: (row[7] as num?)?.toInt() ?? 0,
      timezone: row[8]?.toString() ?? '',
    );
  }
}

double _radians(double degrees) => degrees * math.pi / 180;
