import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

final registerControllerProvider =
    AsyncNotifierProvider.autoDispose<RegisterController, void>(
  RegisterController.new,
);

class RegisterController extends AsyncNotifier<void> {
  late final AuthRepository _repo;

  @override
  FutureOr<void> build() {
    // ❌ jangan async, cukup init biasa
    _repo = ref.read(authRepositoryProvider);
    // ⚠️ Jangan return Future, cukup return void biar gak trigger AsyncData
  }

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordRepeat,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.register(
        name: name,
        username: username,
        email: email,
        password: password,
        passwordRepeat: passwordRepeat,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(Exception(e.toString()), st);
    }
  }
}
