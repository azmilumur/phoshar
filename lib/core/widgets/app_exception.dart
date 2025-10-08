import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  const AppException(this.message);

  /// Mapping otomatis dari Dio -> pesan yang lebih enak dibaca
  factory AppException.fromDio(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;
    final serverMsg = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : null;

    // Auth umum
    if (code == 400 || code == 401) {
      return AppException(serverMsg ?? 'Email atau password salah.');
    }

    // Network umum
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const AppException('Koneksi sedang lambat. Coba lagi.');
    }
    if (e.type == DioExceptionType.badResponse) {
      return AppException(serverMsg ?? 'Terjadi kesalahan pada server.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return const AppException('Tidak ada koneksi internet.');
    }

    return AppException(serverMsg ?? 'Terjadi kesalahan. Coba lagi.');
  }

  @override
  String toString() => message; // supaya SnackBar menampilkan pesannya saja
}
