/// API constants and configuration.
class ApiConstants {
  ApiConstants._();

  static const String baseUrlKey = 'AVIATIONSTACK_BASE_URL';
  static const String apiKeyKey = 'AVIATIONSTACK_API_KEY';
  static const String defaultBaseUrl = 'https://api.aviationstack.com/v1';
  static const String defaultApiKey = '11660cdfda2d631ead58cd4eb1612950';
  
  // Endpoints
  static const String flightsEndpoint = '/flights';
  
  // Query parameters
  static const String accessKey = 'access_key';
  static const String flightNumber = 'flight_number';
  static const String airlineIata = 'airline_iata_code';
  static const String depIata = 'dep_iata';
  static const String arrIata = 'arr_iata';
  static const String flightStatus = 'flight_status';
  static const String limit = 'limit';
}
