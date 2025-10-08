// lib/features/auth/controllers/registers_controller.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../data/auth_repository.dart';

/// Provider autoDispose
final registerControllerProvider =
    AsyncNotifierProvider.autoDispose<RegisterController, void>(
      RegisterController.new,
    );

class RegisterController extends AsyncNotifier<void> {
  // Ambil repo dari ref setiap kali dipakai (aman utk autoDispose)
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  /// build() di v3 boleh `FutureOr<void>` dan boleh kosong
  @override
  FutureOr<void> build() {}

  /// Register:
  /// - kalau `imageFile` ada, upload dulu → dapat URL
  /// - kirim request register (pakai url di atas atau `profilePictureUrl` kalau diisi manual)
  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordRepeat,
    XFile? imageFile,
    String? phoneNumber,
    String? bio,
    String? website,
    String? profilePictureUrl, // jika user isi link langsung
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      String? picUrl = profilePictureUrl;
      if (imageFile != null) {
        picUrl = await _repo.uploadImage(imageFile);
      }

      await _repo.register(
        name: name,
        username: username,
        email: email,
        password: password,
        passwordRepeat: passwordRepeat,
        profilePictureUrl: picUrl,
        phoneNumber: phoneNumber,
        bio: bio,
        website: website,
      );
    });
  }
}
