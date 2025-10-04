import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/networks/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../shared/auth_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStoreProvider),
  );
});

class AuthRepository {
  final ApiClient _api;
  final TokenStore _tokens;

  AuthRepository(this._api, this._tokens);

  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _api.post(
      '/login',
      data: {'email': email, 'password': password},
    );

    final data = res.data as Map<String, dynamic>;

    // ✅ cek kalau gagal login
    if (data['code'] != "200") {
      throw Exception(data['message'] ?? 'Login gagal');
    }

    final userMap = (data['user'] ?? data) as Map<String, dynamic>;
    final token = (data['token'] ?? data['accessToken']) as String;

    await _tokens.saveAccessToken(token);
    return AuthUser.fromMap(userMap);
  }

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordRepeat,
  }) async {
    final res = await _api.post(
      '/register',
      data: {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'passwordRepeat': passwordRepeat,
        'profilePictureUrl': '',
        'phoneNumber': '',
        'bio': '',
        'website': '',
      },
    );

    final data = res.data as Map<String, dynamic>;

    // ✅ cek kalau API balikin error
    if (data['code'] != "200") {
      throw Exception(data['message'] ?? 'Registrasi gagal');
    }
  }

  Future<void> signOut() async {
    await _tokens.clear();
  }

  Future<AuthUser?> getCurrentUser() async {
    final at = await _tokens.getAccessToken();
    if (at == null) return null;
    try {
      final res = await _api.get('/auth/me');
      return AuthUser.fromMap(res.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
