import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/token_storage.dart';
import 'dio_client.dart'; // kalau kamu pakai setup dio yang sama

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ApiClient(dio);
});

class ApiClient {
  ApiClient(this._dio);
  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters, // <- OPSIONAL
    Map<String, dynamic>? headers,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters, // <- opsional juga
    Map<String, dynamic>? headers,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
  }
}
