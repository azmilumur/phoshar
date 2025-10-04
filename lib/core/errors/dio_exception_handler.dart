// lib/core/errors/dio_exception_handler.dart

import 'package:dio/dio.dart';
import 'app_exception.dart';

class DioExceptionHandler {
  static AppException handleDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkException(
          'Connection timeout. Please check your internet connection',
          code: 'CONNECTION_TIMEOUT',
        );

      case DioExceptionType.sendTimeout:
        return const NetworkException(
          'Request timeout. Please try again',
          code: 'SEND_TIMEOUT',
        );

      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'Server response timeout. Please try again',
          code: 'RECEIVE_TIMEOUT',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(dioException);

      case DioExceptionType.cancel:
        return const NetworkException(
          'Request was cancelled',
          code: 'REQUEST_CANCELLED',
        );

      case DioExceptionType.unknown:
        return const NetworkException(
          'Network error. Please check your internet connection',
          code: 'NETWORK_ERROR',
        );

      default:
        return NetworkException(
          'Network error: ${dioException.message}',
          code: 'UNKNOWN_NETWORK_ERROR',
          originalError: dioException,
        );
    }
  }

  static AppException _handleBadResponse(DioException dioException) {
    final statusCode = dioException.response?.statusCode;
    final responseData = dioException.response?.data;
    final errorMessage = responseData is Map<String, dynamic>
        ? responseData['message'] as String?
        : null;

    switch (statusCode) {
      case 400:
        return ValidationException(
          errorMessage ?? 'Invalid request format',
          code: 'BAD_REQUEST',
          originalError: dioException,
        );

      case 401:
        return AuthException(
          errorMessage ?? 'Invalid email or password',
          code: 'UNAUTHORIZED',
          originalError: dioException,
        );

      case 403:
        return AuthException(
          errorMessage ?? 'Access forbidden',
          code: 'FORBIDDEN',
          originalError: dioException,
        );

      case 404:
        return ServerException(
          errorMessage ?? 'Resource not found',
          code: 'NOT_FOUND',
          originalError: dioException,
        );

      case 422:
        return ValidationException(
          errorMessage ?? 'Validation error',
          code: 'VALIDATION_ERROR',
          originalError: dioException,
        );

      case 429:
        return ServerException(
          errorMessage ?? 'Too many requests. Please try again later',
          code: 'TOO_MANY_REQUESTS',
          originalError: dioException,
        );

      case 500:
        return ServerException(
          'Server error. Please try again later',
          code: 'INTERNAL_SERVER_ERROR',
          originalError: dioException,
        );

      case 502:
        return ServerException(
          'Bad gateway. Please try again later',
          code: 'BAD_GATEWAY',
          originalError: dioException,
        );

      case 503:
        return ServerException(
          'Service unavailable. Please try again later',
          code: 'SERVICE_UNAVAILABLE',
          originalError: dioException,
        );

      default:
        return ServerException(
          errorMessage ?? 'Server error occurred',
          code: 'SERVER_ERROR_$statusCode',
          originalError: dioException,
        );
    }
  }
}
