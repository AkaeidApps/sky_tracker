/// Flight model from Aviationstack API response.
library;

import 'dart:convert';
import 'dart:developer' as dev;

class FlightModel {
  final String? flightId;
  final String? flights;
  final AirlineModel? airline;
  final FlightStatusModel? flightStatus;
  final DepartureModel? departure;
  final ArrivalModel? arrival;
  final AircraftModel? aircraft;
  final LivePositionModel? live;

  FlightModel({
    this.flightId,
    this.flights,
    this.airline,
    this.flightStatus,
    this.departure,
    this.arrival,
    this.aircraft,
    this.live,
  });

  /// Constructor for creating mock/booking flights with simple string values.
  FlightModel.mock({
    required this.flightId,
    required String flightNumber,
    required String airlineName,
    required String depIata,
    required String arrIata,
    required String depAirportName,
    required String arrAirportName,
    required String scheduledDeparture,
    required String scheduledArrival,
    required String statusText,
  })  : flights = flightNumber,
        airline = AirlineModel(name: airlineName),
        flightStatus = FlightStatusModel(text: statusText, value: statusText),
        departure = DepartureModel(
          airport: AirportModel(name: depAirportName, iata: depIata),
          time: TimeModel(scheduled: scheduledDeparture),
        ),
        arrival = ArrivalModel(
          airport: AirportModel(name: arrAirportName, iata: arrIata),
          time: TimeModel(scheduled: scheduledArrival),
        ),
        aircraft = null,
        live = null;

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    return FlightModel(
      flightId: json['flight_id']?.toString(),
      flights: _parseFlights(json['flights']),
      airline: _safeMap(json['airline'], (m) => AirlineModel.fromJson(m)),
      flightStatus: json['flight_status'] != null
          ? FlightStatusModel.fromJson(json['flight_status'])
          : null,
      departure: _safeMap(json['departure'], (m) => DepartureModel.fromJson(m)),
      arrival: _safeMap(json['arrival'], (m) => ArrivalModel.fromJson(m)),
      aircraft: _safeMap(json['aircraft'], (m) => AircraftModel.fromJson(m)),
      live: _safeMap(json['live'], (m) => LivePositionModel.fromJson(m)),
    );
  }

  /// Safely parse a dynamic value as a Map, then apply [parser].
  /// If the value is a JSON-encoded String, it will be decoded first.
  /// Returns null if the value cannot be converted to a Map.
  static T? _safeMap<T>(
    dynamic value,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return parser(value);
    if (value is String) {
      // API may return JSON-encoded strings for nested objects
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) return parser(decoded);
      } catch (e) {
        dev.log(
          'Warning: failed to decode JSON string: $e',
          name: 'FlightModel',
        );
      }
    }
    dev.log(
      'Warning: expected Map but got ${value.runtimeType} for value: $value',
      name: 'FlightModel',
    );
    return null;
  }

  static String? _parseFlights(dynamic data) {
    if (data == null) return null;
    if (data is List && data.isNotEmpty) {
      if (data.first is Map) {
        return (data.first as Map)['flight_number']?.toString() ?? '';
      }
    }
    if (data is Map) {
      return data['flight_number']?.toString() ?? '';
    }
    return data.toString();
  }

  String get flightNumber =>
      (flights != null && flights!.isNotEmpty) ? flights! : 'N/A';
  String get airlineName => airline?.name ?? 'Unknown Airline';
  String get airlineIata => airline?.iata ?? '';
  String get depIata => departure?.airport?.iata ?? '';
  String get depAirportName => departure?.airport?.name ?? 'Unknown';
  String get arrIata => arrival?.airport?.iata ?? '';
  String get arrAirportName => arrival?.airport?.name ?? 'Unknown';
  String get statusText => flightStatus?.value ?? 'unknown';
  String? get scheduledDeparture => departure?.time?.scheduled;
  String? get scheduledArrival => arrival?.time?.scheduled;
  String? get estimatedDeparture => departure?.time?.estimated;
  String? get estimatedArrival => arrival?.time?.estimated;
  String? get actualDeparture => departure?.time?.actual;
  String? get actualArrival => arrival?.time?.actual;
  String? get depTerminal => departure?.terminal?.value;
  String? get depGate => departure?.gate?.value;
  String? get arrTerminal => arrival?.terminal?.value;
  String? get arrGate => arrival?.gate?.value;
  String? get aircraftRegistration => aircraft?.registration;
  String? get aircraftModel => aircraft?.model;
  double? get latitude => live?.latitude != null
      ? (live!.latitude is num
            ? (live!.latitude as num).toDouble()
            : double.tryParse(live!.latitude.toString()))
      : null;
  double? get longitude => live?.longitude != null
      ? (live!.longitude is num
            ? (live!.longitude as num).toDouble()
            : double.tryParse(live!.longitude.toString()))
      : null;
  int? get heading => live?.heading != null
      ? (live!.heading is num
            ? (live!.heading as num).toInt()
            : int.tryParse(live!.heading.toString()))
      : null;

  bool get hasLivePosition {
    if (live == null || live!.latitude == null || live!.longitude == null) {
      return false;
    }
    final lat = latitude;
    final lng = longitude;
    // Accept any valid coordinates (not just positive ones)
    // Filter out only the clearly invalid (0,0) origin point
    return lat != null &&
        lng != null &&
        (lat.abs() > 0.001 || lng.abs() > 0.001) &&
        lat.abs() <= 90 &&
        lng.abs() <= 180;
  }

  Map<String, dynamic> toJson() => {
    'flight_id': flightId,
    'flights': flights,
    'airline': airline?.toJson(),
    'flight_status': flightStatus?.toJson(),
    'departure': departure?.toJson(),
    'arrival': arrival?.toJson(),
    'aircraft': aircraft?.toJson(),
    'live': live?.toJson(),
  };
}

class AirlineModel {
  final String? uri;
  final String? name;
  final String? iata;
  final String? icao;

  AirlineModel({this.uri, this.name, this.iata, this.icao});

  factory AirlineModel.fromJson(Map<String, dynamic> json) => AirlineModel(
    uri: json['uri']?.toString(),
    name: json['name']?.toString(),
    iata: json['iata']?.toString(),
    icao: json['icao']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'uri': uri,
    'name': name,
    'iata': iata,
    'icao': icao,
  };
}

class FlightStatusModel {
  final String? text;
  final String? value;
  FlightStatusModel({this.text, this.value});
  factory FlightStatusModel.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return FlightStatusModel(
        text: json['text']?.toString(),
        value: json['value']?.toString(),
      );
    }
    if (json is String) {
      // API may return JSON-encoded string for flight_status
      try {
        final decoded = jsonDecode(json);
        if (decoded is Map<String, dynamic>) {
          return FlightStatusModel(
            text: decoded['text']?.toString(),
            value: decoded['value']?.toString(),
          );
        }
      } catch (_) {
        // Not JSON — treat as plain status text
      }
      return FlightStatusModel(text: json, value: json);
    }
    return FlightStatusModel(text: json?.toString(), value: json?.toString());
  }
  Map<String, dynamic> toJson() => {'text': text, 'value': value};
}

class DepartureModel {
  final AirportModel? airport;
  final TimeModel? time;
  final TerminalModel? terminal;
  final GateModel? gate;
  DepartureModel({this.airport, this.time, this.terminal, this.gate});
  factory DepartureModel.fromJson(Map<String, dynamic> json) => DepartureModel(
    airport: _parseAirport(json['airport']),
    time: _safeMap(json['time'], (m) => TimeModel.fromJson(m)),
    terminal: _safeMap(json['terminal'], (m) => TerminalModel.fromJson(m)),
    gate: _safeMap(json['gate'], (m) => GateModel.fromJson(m)),
  );
  Map<String, dynamic> toJson() => {
    'airport': airport?.toJson(),
    'time': time?.toJson(),
    'terminal': terminal?.toJson(),
    'gate': gate?.toJson(),
  };
}

class ArrivalModel {
  final AirportModel? airport;
  final TimeModel? time;
  final TerminalModel? terminal;
  final GateModel? gate;
  ArrivalModel({this.airport, this.time, this.terminal, this.gate});
  factory ArrivalModel.fromJson(Map<String, dynamic> json) => ArrivalModel(
    airport: _parseAirport(json['airport']),
    time: _safeMap(json['time'], (m) => TimeModel.fromJson(m)),
    terminal: _safeMap(json['terminal'], (m) => TerminalModel.fromJson(m)),
    gate: _safeMap(json['gate'], (m) => GateModel.fromJson(m)),
  );
  Map<String, dynamic> toJson() => {
    'airport': airport?.toJson(),
    'time': time?.toJson(),
    'terminal': terminal?.toJson(),
    'gate': gate?.toJson(),
  };
}

/// Parse airport field which can be a String (IATA code), a JSON-encoded String, a Map, or null.
AirportModel? _parseAirport(dynamic value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return AirportModel.fromJson(value);
  if (value is String) {
    // Try decoding as JSON first (API may return JSON-encoded airport objects)
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) return AirportModel.fromJson(decoded);
    } catch (_) {
      // Not JSON — treat as plain IATA code
    }
    // API sometimes returns just the IATA code as a string
    return AirportModel(iata: value);
  }
  dev.log(
    'Warning: airport field has unexpected type ${value.runtimeType}',
    name: 'FlightModel',
  );
  return null;
}

/// Safely parse a dynamic value as a Map, then apply [parser].
/// If the value is a JSON-encoded String, it will be decoded first.
/// Returns null if the value cannot be converted to a Map.
T? _safeMap<T>(dynamic value, T Function(Map<String, dynamic>) parser) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return parser(value);
  if (value is String) {
    // API may return JSON-encoded strings for nested objects
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) return parser(decoded);
    } catch (e) {
      dev.log(
        'Warning: failed to decode JSON string: $e',
        name: 'FlightModel',
      );
    }
  }
  dev.log(
    'Warning: expected Map but got ${value.runtimeType}',
    name: 'FlightModel',
  );
  return null;
}

class AirportModel {
  final String? name;
  final String? iata;
  final String? icao;
  final String? latitude;
  final String? longitude;
  final String? timezone;
  final String? city;
  final String? country;

  AirportModel({
    this.name,
    this.iata,
    this.icao,
    this.latitude,
    this.longitude,
    this.timezone,
    this.city,
    this.country,
  });

  factory AirportModel.fromJson(Map<String, dynamic> json) => AirportModel(
    name: json['name']?.toString(),
    iata: json['iata']?.toString(),
    icao: json['icao']?.toString(),
    latitude: json['latitude']?.toString(),
    longitude: json['longitude']?.toString(),
    timezone: json['timezone']?.toString(),
    city: json['city']?.toString(),
    country: json['country']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'iata': iata,
    'icao': icao,
    'latitude': latitude,
    'longitude': longitude,
    'timezone': timezone,
    'city': city,
    'country': country,
  };

  double? get lat => latitude != null ? double.tryParse(latitude!) : null;
  double? get lng => longitude != null ? double.tryParse(longitude!) : null;
  bool get hasCoordinates => lat != null && lng != null;
}

class TimeModel {
  final String? scheduled;
  final String? estimated;
  final String? actual;
  final String? utc;
  TimeModel({this.scheduled, this.estimated, this.actual, this.utc});
  factory TimeModel.fromJson(Map<String, dynamic> json) => TimeModel(
    scheduled: json['scheduled']?.toString(),
    estimated: json['estimated']?.toString(),
    actual: json['actual']?.toString(),
    utc: json['utc']?.toString(),
  );
  Map<String, dynamic> toJson() => {
    'scheduled': scheduled,
    'estimated': estimated,
    'actual': actual,
    'utc': utc,
  };
}

class TerminalModel {
  final String? text;
  final String? value;
  TerminalModel({this.text, this.value});
  factory TerminalModel.fromJson(Map<String, dynamic> json) => TerminalModel(
    text: json['text']?.toString(),
    value: json['value']?.toString(),
  );
  Map<String, dynamic> toJson() => {'text': text, 'value': value};
}

class GateModel {
  final String? text;
  final String? value;
  GateModel({this.text, this.value});
  factory GateModel.fromJson(Map<String, dynamic> json) => GateModel(
    text: json['text']?.toString(),
    value: json['value']?.toString(),
  );
  Map<String, dynamic> toJson() => {'text': text, 'value': value};
}

class AircraftModel {
  final String? registration;
  final String? model;
  final String? icao24;

  AircraftModel({this.registration, this.model, this.icao24});

  factory AircraftModel.fromJson(Map<String, dynamic> json) => AircraftModel(
    registration: json['registration']?.toString(),
    model: json['model']?.toString(),
    icao24: json['icao24']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'registration': registration,
    'model': model,
    'icao24': icao24,
  };
}

class LivePositionModel {
  final dynamic latitude;
  final dynamic longitude;
  final dynamic altitude;
  final dynamic speed;
  final dynamic heading;
  final dynamic verticalSpeed;
  final dynamic groundSpeed;
  final dynamic lastContact;

  LivePositionModel({
    this.latitude,
    this.longitude,
    this.altitude,
    this.speed,
    this.heading,
    this.verticalSpeed,
    this.groundSpeed,
    this.lastContact,
  });

  factory LivePositionModel.fromJson(Map<String, dynamic> json) =>
      LivePositionModel(
        latitude: json['latitude'],
        longitude: json['longitude'],
        altitude: json['altitude'],
        speed: json['speed'],
        heading: json['heading'],
        verticalSpeed: json['vertical_speed'],
        groundSpeed: json['ground_speed'],
        lastContact: json['last_contact'],
      );

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'altitude': altitude,
    'speed': speed,
    'heading': heading,
    'vertical_speed': verticalSpeed,
    'ground_speed': groundSpeed,
    'last_contact': lastContact,
  };
}
