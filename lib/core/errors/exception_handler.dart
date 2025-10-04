// lib/core/errors/exception_handler.dart

import 'package:dio/dio.dart';
import 'app_exception.dart';
import 'dio_exception_handler.dart';

class ExceptionHandler {
  /// Handles any exception and converts it to AppException
  static AppException handleException(dynamic exception) {
    if (exception is AppException) {
      return exception;
    }

    if (exception is DioException) {
      return DioExceptionHandler.handleDioException(exception);
    }

    // Handle other common exceptions
    if (exception is FormatException) {
      return ValidationException(
        'Invalid data format: ${exception.message}',
        code: 'FORMAT_ERROR',
        originalError: exception,
      );
    }

    if (exception is TypeError) {
      return UnknownException(
        'Type error occurred: ${exception.toString()}',
        code: 'TYPE_ERROR',
        originalError: exception,
      );
    }

    // Default case for unknown exceptions
    return UnknownException(
      'Unexpected error occurred: ${exception.toString()}',
      code: 'UNKNOWN_ERROR',
      originalError: exception,
    );
  }

  /// Executes a function and handles any exceptions
  static Future<T> handleAsync<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      throw handleException(e);
    }
  }

  /// Executes a synchronous function and handles any exceptions
  static T handleSync<T>(T Function() operation) {
    try {
      return operation();
    } catch (e) {
      throw handleException(e);
    }
  }
}
