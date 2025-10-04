// lib/core/errors/error_messages.dart

class ErrorMessages {
  // Authentication errors
  static const String invalidCredentials = 'Invalid email or password';
  static const String tokenExpired = 'Session expired. Please login again';
  static const String accessDenied = 'Access denied';
  static const String accountNotFound = 'Account not found';
  static const String accountDisabled = 'Account has been disabled';

  // Network errors
  static const String noInternetConnection = 'No internet connection';
  static const String connectionTimeout =
      'Connection timeout. Please check your internet connection';
  static const String serverTimeout =
      'Server response timeout. Please try again';
  static const String networkError =
      'Network error. Please check your internet connection';

  // Server errors
  static const String serverError = 'Server error. Please try again later';
  static const String serviceUnavailable =
      'Service unavailable. Please try again later';
  static const String badGateway = 'Bad gateway. Please try again later';
  static const String tooManyRequests =
      'Too many requests. Please try again later';

  // Validation errors
  static const String invalidRequestFormat = 'Invalid request format';
  static const String validationError = 'Validation error';
  static const String requiredFieldMissing = 'Required field is missing';
  static const String invalidDataFormat = 'Invalid data format';

  // Cache errors
  static const String cacheError = 'Cache error occurred';
  static const String dataNotFound = 'Data not found';

  // General errors
  static const String unexpectedError = 'Unexpected error occurred';
  static const String operationFailed = 'Operation failed';
  static const String requestCancelled = 'Request was cancelled';
}
