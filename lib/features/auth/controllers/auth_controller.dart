import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../shared/auth_user.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthUser?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AuthUser?> {
  late final AuthRepository _repo;

  @override
  Future<AuthUser?> build() async {
    _repo = ref.read(authRepositoryProvider);
    try {
      final user = await _repo.getCurrentUser();
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _repo.signIn(email: email, password: password);
      debugPrint("🔥 AuthController user: ${user.email}");
      return user;
    });
  }

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordRepeat,
  }) async {
    state = const AsyncLoading();
    debugPrint('🟡 [AuthController] Mulai register...');

    state = await AsyncValue.guard(() async {
      try {
        await _repo.register(
          name: name,
          username: username,
          email: email,
          password: password,
          passwordRepeat: passwordRepeat,
        );
        debugPrint('🟢 [AuthController] Register sukses');
        return null;
      } catch (e) {
        debugPrint('🔴 [AuthController] Register gagal: $e');
        rethrow;
      }
    });
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AsyncData(null);
  }
}
