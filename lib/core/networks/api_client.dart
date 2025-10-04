import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_client.dart';

class ApiClient {
  final Dio _dio;
  ApiClient(this._dio);

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) {
    return _dio.get(path, queryParameters: query);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response<T>> delete<T>(String path, {dynamic data}) {
    return _dio.delete(path, data: data);
  }
}

// Provider ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioClientProvider); // ambil dari dio_client.dart
  return ApiClient(dio);
});
