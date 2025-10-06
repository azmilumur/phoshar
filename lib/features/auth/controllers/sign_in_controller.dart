// lib/features/auth/controllers/sign_in_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../data/auth_repository.dart';
import 'session_controller.dart';

final signInControllerProvider =
    AsyncNotifierProvider.autoDispose<SignInController, void>(
      SignInController.new,
    );

class SignInController extends AsyncNotifier<void> {
  late final AuthRepository _repo;

  @override
  Future<void> build() async {
    _repo = ref.read(authRepositoryProvider);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await _repo.signIn(email: email, password: password);

      // Update session -> router auto-redirect
      ref.read(sessionControllerProvider.notifier).setUser(user);

      state = const AsyncData(null);
    } on DioException catch (e, st) {
      state = AsyncError(Exception(_formatDio(e)), st);
    } catch (e, st) {
      state = AsyncError(Exception(e.toString()), st);
    }
  }

  String _formatDio(DioException e) {
    final d = e.response?.data;
    if (d is Map && d['message'] is String) return d['message'] as String;
    return e.message ?? 'Login gagal';
  }
}
