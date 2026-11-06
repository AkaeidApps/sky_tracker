import 'package:dio/dio.dart';

/// Dedicated client for the OpenSky Network live-aircraft API.
///
/// It is intentionally separate from the Aviationstack client: different host,
/// longer timeouts (a global snapshot can be ~1 MB) and no API key required.
class OpenSkyClient {
  OpenSkyClient._();

  static const String baseUrl = 'https://opensky-network.org/api';

  static Dio? _dio;

  static Dio get instance {
    _dio ??= Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 35),
        headers: const {
          'Accept': 'application/json',
        },
      ),
    );
    return _dio!;
  }

  static void reset() {
    _dio = null;
  }
}
