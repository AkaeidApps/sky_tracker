import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:sky_tracker/core/error/exceptions.dart';
import 'package:sky_tracker/core/network/api_client.dart';
import 'package:sky_tracker/core/network/api_constants.dart';
import 'package:sky_tracker/data/models/flight_model.dart';

final _logger = Logger();

/// Service for fetching flight data from Aviationstack API.
class FlightService {
  final Dio _dio = ApiClient.instance;

  /// Get the API key from environment variables.
  String _getApiKey() {
    final apiKey = dotenv.isInitialized
        ? (dotenv.maybeGet(ApiConstants.apiKeyKey, fallback: ApiConstants.defaultApiKey) ??
            ApiConstants.defaultApiKey)
        : ApiConstants.defaultApiKey;
    if (apiKey.isEmpty || apiKey == 'your_api_key_here') {
      _logger.e('AVIATIONSTACK_API_KEY is not set in .env file.');
    }
    return apiKey;
  }

  /// Fetch flights with optional filters.
  Future<List<FlightModel>> getFlights({
    String? flightNumber,
    String? airlineIata,
    String? depIata,
    String? arrIata,
    String? flightStatus,
    int? limit,
  }) async {
    try {
      final apiKey = _getApiKey();
      if (apiKey.isEmpty || apiKey == 'your_api_key_here') {
        throw ApiException(
          message: 'API key not configured. Please set AVIATIONSTACK_API_KEY in your .env file.',
        );
      }

      final queryParams = <String, dynamic>{ApiConstants.accessKey: apiKey};

      if (flightNumber != null && flightNumber.isNotEmpty) {
        queryParams[ApiConstants.flightNumber] = flightNumber;
      }
      if (airlineIata != null && airlineIata.isNotEmpty) {
        queryParams[ApiConstants.airlineIata] = airlineIata;
      }
      if (depIata != null && depIata.isNotEmpty) {
        queryParams[ApiConstants.depIata] = depIata;
      }
      if (arrIata != null && arrIata.isNotEmpty) {
        queryParams[ApiConstants.arrIata] = arrIata;
      }
      if (flightStatus != null && flightStatus.isNotEmpty) {
        queryParams[ApiConstants.flightStatus] = flightStatus;
      }
      if (limit != null) {
        queryParams[ApiConstants.limit] = limit;
      }

      final response = await _dio.get(
        ApiConstants.flightsEndpoint,
        queryParameters: queryParams,
      );

      if (response.data == null) {
        return [];
      }

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {};
      final errors = data['errors'];
      if (errors != null && errors is Map && errors.isNotEmpty) {
        final errorMsg = errors.values.first.toString();
        throw ApiException(message: errorMsg);
      }

      final dataArr = data['data'] as List?;
      if (dataArr == null || dataArr.isEmpty) {
        return [];
      }

      return dataArr
          .where((item) => item is Map<String, dynamic> || item is String)
          .map((item) {
            // API may return JSON-encoded strings instead of maps
            if (item is Map<String, dynamic>) {
              return FlightModel.fromJson(item);
            }
            if (item is String) {
              try {
                final decoded = jsonDecode(item);
                if (decoded is Map<String, dynamic>) {
                  return FlightModel.fromJson(decoded);
                }
              } catch (e) {
                _logger.w('Failed to decode flight data string: $e');
              }
            }
            return null;
          })
          .whereType<FlightModel>()
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } on ApiException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.e('Unexpected error in getFlights: $e', stackTrace: stackTrace);
      throw ApiException(
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Check API connectivity.
  Future<bool> checkConnection() async {
    try {
      final apiKey = _getApiKey();
      if (apiKey.isEmpty || apiKey == 'your_api_key_here') return false;

      await _dio.get(
        ApiConstants.flightsEndpoint,
        queryParameters: {
          ApiConstants.accessKey: apiKey,
          ApiConstants.limit: 1,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
