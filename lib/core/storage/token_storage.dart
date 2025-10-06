// lib/core/storage/token_storage.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  const TokenStore(this._storage);
  final FlutterSecureStorage _storage;

  static const _kAccess = 'accessToken';
  static const _kRefresh = 'refreshToken';
  static const _kUser = 'authUser'; // ⬅️ NEW

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _kAccess, value: token);
  Future<String?> getAccessToken() => _storage.read(key: _kAccess);

  Future<void> saveTokens({required String access, String? refresh}) async {
    await _storage.write(key: _kAccess, value: access);
    if (refresh != null) {
      await _storage.write(key: _kRefresh, value: refresh);
    }
  }

  // ⬇️ NEW: simpan/baca user (Map) sebagai JSON
  Future<void> saveUserMap(Map<String, dynamic> user) async {
    await _storage.write(key: _kUser, value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUserMap() async {
    final s = await _storage.read(key: _kUser);
    if (s == null) return null;
    try {
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kUser); // ⬅️ NEW
  }
}
