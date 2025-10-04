// lib/core/constants/app_constants.dart

class AppConstants {
  static const String baseUrl = 'https://dummyjson.com';
  static const String lumeBaseUrl =
      'https://photo-sharing-api-bootcamp.do.dibimbing.id';
  static const String apiKey = 'c7b411cc-0e7c-4ad1-aa3f-822b00e7734b';

  // Private endpoints
  static const List<String> privateEndpoints = [
    '/api/v1/user',
    '/api/v1/posts',
    '/api/v1/comments',
    '/api/v1/follow',
    '/api/v1/story',
    '/api/v1/logout',
  ];
}
