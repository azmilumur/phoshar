import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/register_repository.dart';
import '../../shared/auth_user.dart';
import '../domain/register_request.dart';

final registerProvider = AsyncNotifierProvider<RegisterController, AuthUser?>(
  RegisterController.new,
);

class RegisterController extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() async {
    return null; // default: belum login
  }

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordRepeat,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(registerRepositoryProvider);
      // hanya kirim data register
      await repo.register(
        RegisterRequest(
          name: name,
          username: username,
          email: email,
          password: password,
          passwordRepeat: passwordRepeat,
        ),
      );

      // register berhasil → return null (atau dummy AuthUser kalau mau)
      return null;
    });
  }
}
