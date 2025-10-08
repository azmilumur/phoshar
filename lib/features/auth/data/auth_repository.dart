import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/networks/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/auth_user.dart';

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
    final token = (data['token'] ?? data['accessToken'] ?? '').toString();

    if (token.isEmpty) throw Exception('Login gagal: Username Password Salah');
    await _tokens.saveAccessToken(token);

    final userMap =
        (data['user'] ?? data['data']?['user'] ?? data) as Map<String, dynamic>;
    await _tokens.saveUserMap(userMap);
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
      },
    );

    final data = res.data as Map<String, dynamic>;
    if (data['code'] != '200') {
      throw Exception(data['message'] ?? 'Registrasi gagal');
    }
  }

  Future<void> signOut() async {
    await _tokens.clear();
  }

  Future<AuthUser?> restoreSession() async {
    final token = await _tokens.getAccessToken();
    if (token == null) return null;
    final map = await _tokens.getUserMap();
    if (map == null) return null;
    return AuthUser.fromMap(map);
  }
}
