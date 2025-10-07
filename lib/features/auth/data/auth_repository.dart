import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';

// ---- Model user (tak berubah) ----
class AuthUser {
  final String id;
  final String email;
  final String? username,
      name,
      role,
      profilePictureUrl,
      phoneNumber,
      bio,
      website;
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

// ---- Providers ----
final tokenStoreProvider = Provider(
  (ref) => TokenStore(const FlutterSecureStorage()),
);
final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    ref.watch(dioClientProvider),
    ref.watch(tokenStoreProvider),
  ),
);

// ---- Repository ----
class AuthRepository {
  AuthRepository(this._dio, this._tokens);
  final Dio _dio;
  final TokenStore _tokens;

  Future<void> logout() async {
    try {
      await _dio.get('/logout'); // GET /api/v1/logout
    } catch (_) {
      // abaikan error jaringan/server; yang penting token dibersihkan
    } finally {
      await _tokens.clear();
    }
  }

  // LOGIN: simpan token + user untuk session restore
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      'login',
      data: {'email': email, 'password': password},
    );
    final map = res.data as Map<String, dynamic>;
    final token = (map['token'] ?? map['accessToken'] ?? '').toString();
    if (token.isEmpty) throw Exception('Login gagal: token kosong');
    await _tokens.saveAccessToken(token);

    final userMap =
        (map['user'] ?? map['data']?['user'] ?? map) as Map<String, dynamic>;
    await _tokens.saveUserMap(userMap);
    return AuthUser.fromMap(userMap);
  }

  // REGISTER: sesuai API kamu (TIDAK mengembalikan token) -> return void
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
    final payload = {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'passwordRepeat': passwordRepeat,
      if (profilePictureUrl != null && profilePictureUrl.isNotEmpty)
        'profilePictureUrl': profilePictureUrl,
      if (phoneNumber != null && phoneNumber.isNotEmpty)
        'phoneNumber': phoneNumber,
      if (bio != null) 'bio': bio,
      if (website != null) 'website': website,
    };

    final res = await _dio.post(
      'register',
      data: payload,
    ); // TANPA leading slash
    if ((res.statusCode ?? 0) >= 400) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'Register gagal',
        type: DioExceptionType.badResponse,
      );
    }
    // no token -> tidak sentuh TokenStore di sini
  }

  // Session restore dari storage (karena tidak ada /auth/me)
  Future<AuthUser?> restoreSession() async {
    final at = await _tokens.getAccessToken();
    if (at == null) return null;
    final map = await _tokens.getUserMap();
    if (map == null) return null;
    return AuthUser.fromMap(map);
  }

  Future<void> signOut() async => _tokens.clear();
}
