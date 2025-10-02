import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:phoshar/core/config/env.dart';
import 'package:phoshar/core/storage/token_storage.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final tokenStore = TokenStore(const FlutterSecureStorage());
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.baseUrl, // sudah /api/v1
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        // beberapa API pakai "apiKey", sebagian "x-api-key"—kirim dua-duanya aman
        'apiKey': EnvConfig.apiKey,
        'x-api-key': EnvConfig.apiKey,
        'Content-Type': 'application/json',
      },
      validateStatus: (status) => true, // biar bisa lihat body saat 401
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // jangan kirim Authorization ke login/register
        final p = options.path; // contoh: 'login' atau '/login'
        final isAuthPath = p.contains('login') || p.contains('register');

        if (!isAuthPath) {
          final accessToken = await tokenStore.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
        }
        return handler.next(options);
      },
    ),
  );

  // sementara aktifkan logger untuk debug (hapus bila sudah stabil)
  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
    ),
  );

  return dio;
});
