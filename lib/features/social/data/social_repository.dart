import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networks/dio_client.dart'; // dioClientProvider

/// ===== Models =====

class MiniUser {
  final String id;
  final String? username;
  final String? email;
  final String? profilePictureUrl;

  const MiniUser({
    required this.id,
    this.username,
    this.email,
    this.profilePictureUrl,
  });

  factory MiniUser.fromMap(Map<String, dynamic> m) => MiniUser(
    id: (m['id'] ?? '').toString(),
    username: m['username'] as String?,
    email: m['email'] as String?,
    profilePictureUrl: m['profilePictureUrl'] as String?,
  );
}

class PagedUsers {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<MiniUser> users;

  const PagedUsers({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.users,
  });

  factory PagedUsers.empty() =>
      const PagedUsers(totalItems: 0, totalPages: 0, currentPage: 1, users: []);
}

/// ===== Repository =====

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return SocialRepository(dio);
});

class SocialRepository {
  SocialRepository(this._dio);
  final Dio _dio;

  /// POST /api/v1/follow  body: { "userIdFollow": "<id>" }
  /// Sukses atau "You already follow this user" → kembalikan true.
  Future<bool> follow(String userId) async {
    try {
      final res = await _dio.post('follow', data: {'userIdFollow': userId});
      final status = (res.data?['status'] ?? '').toString().toUpperCase();
      if (status == 'OK' || status == 'SUCCESS') return true;
      return true; // anggap sukses bila format berbeda
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? '';
      // server kadang mengirim 404 dengan status "CONFLICT" utk already follow
      if (msg.toLowerCase().contains('already follow')) return true;
      rethrow;
    }
  }

  /// DELETE /api/v1/unfollow/{USER_ID}
  /// Bila sukses → kembalikan false (sekarang sudah tidak follow).
  Future<bool> unfollow(String userId) async {
    await _dio.delete('unfollow/$userId');
    return false;
  }

  /// GET /api/v1/my-following?size=&page=
  Future<PagedUsers> myFollowing({int page = 1, int size = 18}) async {
    final res = await _dio.get(
      'my-following',
      queryParameters: {'page': page, 'size': size},
    );
    return _parsePagedUsers(res.data);
  }

  /// GET /api/v1/my-followers?size=&page=
  Future<PagedUsers> myFollowers({int page = 1, int size = 18}) async {
    final res = await _dio.get(
      'my-followers',
      queryParameters: {'page': page, 'size': size},
    );
    return _parsePagedUsers(res.data);
  }

  /// GET /api/v1/following/{USER_ID}?size=&page=
  Future<PagedUsers> followingOf(
    String userId, {
    int page = 1,
    int size = 18,
  }) async {
    final res = await _dio.get(
      'following/$userId',
      queryParameters: {'page': page, 'size': size},
    );
    return _parsePagedUsers(res.data);
  }

  /// GET /api/v1/followers/{USER_ID}?size=&page=
  Future<PagedUsers> followersOf(
    String userId, {
    int page = 1,
    int size = 18,
  }) async {
    final res = await _dio.get(
      'followers/$userId',
      queryParameters: {'page': page, 'size': size},
    );
    return _parsePagedUsers(res.data);
  }

  /// ===== Parser util =====
  PagedUsers _parsePagedUsers(dynamic raw) {
    try {
      final data = (raw?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
      final usersList = (data['users'] as List?) ?? const [];
      final users = usersList
          .whereType<Map>()
          .map((m) => MiniUser.fromMap(m.cast<String, dynamic>()))
          .toList();

      final totalItems = (data['totalItems'] as num?)?.toInt() ?? users.length;
      final totalPages = (data['totalPages'] as num?)?.toInt() ?? 1;
      final currentPage = (data['currentPage'] as num?)?.toInt() ?? 1;

      return PagedUsers(
        totalItems: totalItems,
        totalPages: totalPages,
        currentPage: currentPage,
        users: users,
      );
    } catch (_) {
      return PagedUsers.empty();
    }
  }
}
