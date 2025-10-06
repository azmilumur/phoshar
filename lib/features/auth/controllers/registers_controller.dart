import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/auth_repository.dart';

final registerControllerProvider =
    AsyncNotifierProvider.autoDispose<RegisterController, void>(
      RegisterController.new,
    );

class RegisterController extends AsyncNotifier<void> {
  late final AuthRepository _repo;

  @override
  Future<void> build() async {
    _repo = ref.read(authRepositoryProvider);
  }

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordRepeat,
    String? profilePictureUrl,
    String? phoneNumber,
    String? bio,
    String? website,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.register(
        name: name,
        username: username,
        email: email,
        password: password,
        passwordRepeat: passwordRepeat,
        profilePictureUrl: profilePictureUrl,
        phoneNumber: phoneNumber,
        bio: bio,
        website: website,
      );
      state = const AsyncData(null); // sukses; UI arahkan ke /login
    } on DioException catch (e, st) {
      final msg =
          (e.response?.data is Map && e.response?.data['message'] is String)
          ? e.response!.data['message'] as String
          : (e.message ?? 'Register gagal');
      state = AsyncError(Exception(msg), st);
    } catch (e, st) {
      state = AsyncError(Exception(e.toString()), st);
    }
  }
}
