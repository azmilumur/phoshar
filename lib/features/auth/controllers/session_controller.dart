import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoshar/features/auth/controllers/register_controller.dart';
import 'package:phoshar/features/auth/controllers/sign_in_controller.dart';
import 'package:phoshar/features/auth/domain/auth_user.dart';
import '../data/auth_repository.dart';

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, AuthUser?>(SessionController.new);

class SessionController extends AsyncNotifier<AuthUser?> {
  AuthRepository? _repo;

  @override
  Future<AuthUser?> build() async {
    _repo ??= ref.read(authRepositoryProvider);
    return null;
  }

  void setUser(AuthUser? user) => state = AsyncData(user);

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await _repo?.signOut();
    } finally {
      state = const AsyncData(null);

      ref.invalidate(signInControllerProvider);
      ref.invalidate(registerControllerProvider);
    }
  }
}
