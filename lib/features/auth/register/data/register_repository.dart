import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networks/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../shared/auth_user.dart';
import '../domain/register_request.dart';

final registerRepositoryProvider = Provider<RegisterRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenStore = ref.watch(tokenStoreProvider);
  return RegisterRepository(apiClient, tokenStore);
});

class RegisterRepository {
  final ApiClient _api;
  final TokenStore _tokenStore;

  RegisterRepository(this._api, this._tokenStore);

  Future<AuthUser> register(RegisterRequest req) async {
    final res = await _api.post('/register', data: req.toJson());

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
