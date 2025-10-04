import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  const TokenStore(this._storage);
  final FlutterSecureStorage _storage;

  static const _kAccess = 'accessToken';
  static const _kRefresh = 'refreshToken';

  // Simpan hanya access token (sesuai payload login kamu)
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _kAccess, value: token);

  // Opsional: kalau nanti punya refresh token juga
  Future<void> saveTokens({required String access, String? refresh}) async {
    await _storage.write(key: _kAccess, value: access);
    if (refresh != null) {
      await _storage.write(key: _kRefresh, value: refresh);
    }
  }

  Future<String?> getAccessToken() => _storage.read(key: _kAccess);
  Future<String?> getRefreshToken() => _storage.read(key: _kRefresh);

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore(const FlutterSecureStorage());
});
