import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/login_repository.dart';
import '../../shared/auth_user.dart';
import '../domain/login_request.dart';

final loginProvider = AsyncNotifierProvider<LoginController, AuthUser?>(
  LoginController.new,
);

class LoginController extends AsyncNotifier<AuthUser?> {
  late final LoginRepository _repo;

  @override
  Future<AuthUser?> build() async {
    _repo = ref.read(loginRepositoryProvider);
    return null; // default: belum login
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _repo.login(LoginRequest(email: email, password: password));
      return user;
    });
  }
}
