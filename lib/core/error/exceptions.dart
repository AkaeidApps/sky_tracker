import 'package:dio/dio.dart';

/// Custom exception classes for API errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        if (error.response != null) {
          return ApiException.fromResponse(error.response!);
        }
        return ApiException(message: 'Bad response from server.');
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection. Please check your network.',
        );
      case DioExceptionType.cancel:
        return ApiException(message: 'Request cancelled.');
      case DioExceptionType.badCertificate:
        return ApiException(message: 'SSL certificate error.');
      case DioExceptionType.unknown:
        return ApiException(message: 'An unexpected error occurred.');
    }
  }

  factory ApiException.fromResponse(Response response) {
    final statusCode = response.statusCode;
    final data = response.data;

    String message;
    if (data is Map && data['error'] != null) {
      message = data['error']['message'] ?? 'Server error';
    } else {
      message = _getDefaultMessage(statusCode);
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
    );
  }

  static String _getDefaultMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please check your API key.';
      case 403:
        return 'Forbidden. Access denied.';
      case 404:
        return 'Resource not found.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Internal server error.';
      default:
        return 'An error occurred (status $statusCode).';
    }
  }

  @override
  String toString() => 'ApiException(status: $statusCode, message: $message)';
}
