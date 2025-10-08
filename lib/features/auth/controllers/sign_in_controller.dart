import 'package:flutter_riverpod/flutter_riverpod.dart';
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

      // 🔄 update ke session controller (biar router login → feed)
      ref.read(sessionControllerProvider.notifier).setUser(user);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(Exception(e.toString()), st);
    }
  }
}
