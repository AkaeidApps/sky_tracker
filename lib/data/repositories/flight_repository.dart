import 'package:sky_tracker/core/services/flight_service.dart';
import 'package:sky_tracker/data/models/flight_model.dart';

/// Repository for flight data.
class FlightRepository {
  final FlightService _service = FlightService();

  Future<List<FlightModel>> getFlights({
    String? flightNumber,
    String? airlineIata,
    String? depIata,
    String? arrIata,
    String? flightStatus,
    int? limit,
  }) => _service.getFlights(
        flightNumber: flightNumber,
        airlineIata: airlineIata,
        depIata: depIata,
        arrIata: arrIata,
        flightStatus: flightStatus,
        limit: limit,
      );

  Future<bool> checkConnection() => _service.checkConnection();
}
