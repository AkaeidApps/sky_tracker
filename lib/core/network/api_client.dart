import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sky_tracker/core/network/api_constants.dart';

/// Centralized Dio client for all API requests.
class ApiClient {
  ApiClient._();

  static Dio? _dio;

  static Dio get instance {
    final baseUrl = dotenv.isInitialized
        ? (dotenv.maybeGet(ApiConstants.baseUrlKey, fallback: ApiConstants.defaultBaseUrl) ??
            ApiConstants.defaultBaseUrl)
        : ApiConstants.defaultBaseUrl;

    _dio ??= Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    return _dio!;
  }

  /// Reset the instance (useful for testing).
  static void reset() {
    _dio = null;
  }
}
