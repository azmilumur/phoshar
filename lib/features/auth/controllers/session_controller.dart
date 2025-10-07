import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, AuthUser?>(SessionController.new);

class SessionController extends AsyncNotifier<AuthUser?> {
  late final AuthRepository _repo;

  @override
  Future<AuthUser?> build() async {
    _repo = ref.read(authRepositoryProvider);
    // Boleh null kalau belum login; kalau server-mu tak punya /auth/me, return null aja.
    return _repo.restoreSession();
  }

  /// Dipanggil oleh SignInController setelah login berhasil
  void setUser(AuthUser? user) => state = AsyncData(user);

  Future<void> signOut() async {
    // boleh tampilkan loading singkat
    state = const AsyncLoading();
    try {
      await _repo.logout();
    } finally {
      // kosongkan sesi
      state = const AsyncData(null);
      // optional: invalidate provider lain jika perlu
      // ref.invalidate(postsRepositoryProvider);
    }
  }
}
