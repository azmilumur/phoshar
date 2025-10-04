import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networks/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../shared/auth_user.dart';
import '../domain/login_request.dart';

/// Provider repository untuk Login
final loginRepositoryProvider = Provider<LoginRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenStore = ref.watch(tokenStoreProvider);
  return LoginRepository(apiClient, tokenStore);
});

/// Repository Login
class LoginRepository {
  final ApiClient _api;
  final TokenStore _tokenStore;

  LoginRepository(this._api, this._tokenStore);

  Future<AuthUser> login(LoginRequest req) async {
    final res = await _api.post('/login', data: req.toJson());

    final raw = res.data;
    if (raw is! Map<String, dynamic>) {
      throw Exception("Invalid response: $raw");
    }

    final data = raw;
    final userMap = data['user'] as Map<String, dynamic>;

    final token = data['token'] as String;
    await _tokenStore.saveAccessToken(token);

    return AuthUser.fromMap(userMap);
  }
}
