// lib/core/errors/errors.dart

export 'app_exception.dart';
export 'dio_exception_handler.dart';
export 'exception_handler.dart';
export 'error_messages.dart';


// In any repository
/*
Future<SomeResponse> someMethod() async {
  return await ExceptionHandler.handleAsync(() async {
    // Your API call here
    final response = await _dio.get('/some-endpoint');
    return SomeResponseModel.fromJson(response.data);
  });
}
*/

// In any UI
/*
try {
  await repository.login(request);
} on AuthException catch (e) {
  // Handle authentication errors specifically
  showErrorMessage('Authentication failed: ${e.message}');
} on NetworkException catch (e) {
  // Handle network errors specifically
  showErrorMessage('Network issue: ${e.message}');
} on AppException catch (e) {
  // Handle any other app exceptions
  showErrorMessage(e.message);
}
*/