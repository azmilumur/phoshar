import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthUser {
  final String id;
  final String email;
  final String? username;
  final String? name;
  final String? role;
  final String? profilePictureUrl;
  final String? phoneNumber;
  final String? bio;
  final String? website;

  const AuthUser({
    required this.id,
    required this.email,
    this.username,
    this.name,
    this.role,
    this.profilePictureUrl,
    this.phoneNumber,
    this.bio,
    this.website,
  });

  factory AuthUser.fromMap(Map<String, dynamic> m) => AuthUser(
    id: (m['id'] ?? '').toString(),
    email: (m['email'] ?? '').toString(),
    username: m['username'] as String?,
    name: m['name'] as String?,
    role: m['role'] as String?,
    profilePictureUrl: m['profilePictureUrl'] as String?,
    phoneNumber: m['phoneNumber'] as String?,
    bio: m['bio'] as String?,
    website: m['website'] as String?,
  );
}

final tokenStoreProvider = Provider<TokenStore>(
  (ref) => TokenStore(const FlutterSecureStorage()),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(dioClientProvider),
    ref.watch(tokenStoreProvider),
  );
});

class AuthRepository {
  AuthRepository(this._dio, this._tokens);
  final Dio _dio;
  final TokenStore _tokens;

  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      '/login',
      data: {'email': email, 'password': password},
    );
    final data = res.data as Map<String, dynamic>;
    final userMap = (data['user'] ?? data) as Map<String, dynamic>;
    final token = (data['token'] ?? data['accessToken']) as String;
    await _tokens.saveAccessToken(token);
    return AuthUser.fromMap(userMap);
  }

  Future<AuthUser> register({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      '/auth/register',
      data: {'email': email, 'password': password},
    );
    final data = res.data as Map<String, dynamic>;
    final userMap = (data['user'] ?? data) as Map<String, dynamic>;
    final token = (data['token'] ?? data['accessToken']) as String;
    await _tokens.saveAccessToken(token);
    return AuthUser.fromMap(userMap);
  }

  Future<void> signOut() async {
    await _tokens.clear();
  }

  Future<AuthUser?> getCurrentUser() async {
    final at = await _tokens.getAccessToken();
    if (at == null) return null;
    try {
      final res = await _dio.get('/auth/me');
      return AuthUser.fromMap(res.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
