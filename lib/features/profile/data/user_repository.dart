// lib/features/profile/data/user_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(ref.watch(dioClientProvider)),
);

enum FollowResult { followed, alreadyFollowing }

class FollowCounts {
  final int posts, followers, following;
  const FollowCounts({
    required this.posts,
    required this.followers,
    required this.following,
  });
}

class UserRepository {
  UserRepository(this._dio);
  final Dio _dio;

  /// FOLLOW (idempotent)
  Future<FollowResult> follow(String userId) async {
    try {
      await _dio.post('follow', data: {'userIdFollow': userId});
      return FollowResult.followed;
    } on DioException catch (e) {
      final d = e.response?.data;
      final status = (d is Map)
          ? (d['status']?.toString().toUpperCase())
          : null;
      final msg = (d is Map && d['message'] is String)
          ? d['message'] as String
          : '';
      if (status == 'CONFLICT' ||
          msg.toLowerCase().contains('already follow')) {
        // server-mu mengirim "404" + status "CONFLICT" → treat as success
        return FollowResult.alreadyFollowing;
      }
      rethrow;
    }
  }

  /// UNFOLLOW
  Future<void> unfollow(String userId) async {
    await _dio.delete('unfollow/$userId');
  }

  /// Hitung total untuk **profil diri sendiri**
  Future<FollowCounts> getMyCounts(String userId) async {
    final postsRes = await _dio.get(
      'users-post/$userId',
      queryParameters: {'size': 1, 'page': 1},
    );
    final posts = (postsRes.data['data']?['totalItems'] as int?) ?? 0;

    final followersRes = await _dio.get(
      'my-followers',
      queryParameters: {'size': 1, 'page': 1},
    );
    final followers = (followersRes.data['data']?['totalItems'] as int?) ?? 0;

    final followingRes = await _dio.get(
      'my-following',
      queryParameters: {'size': 1, 'page': 1},
    );
    final following = (followingRes.data['data']?['totalItems'] as int?) ?? 0;

    return FollowCounts(
      posts: posts,
      followers: followers,
      following: following,
    );
  }

  /// Hitung total untuk **profil user lain**
  Future<FollowCounts> getCountsOf(String userId) async {
    final postsRes = await _dio.get(
      'users-post/$userId',
      queryParameters: {'size': 1, 'page': 1},
    );
    final posts = (postsRes.data['data']?['totalItems'] as int?) ?? 0;

    final followersRes = await _dio.get(
      'followers/$userId',
      queryParameters: {'size': 1, 'page': 1},
    );
    final followers = (followersRes.data['data']?['totalItems'] as int?) ?? 0;

    final followingRes = await _dio.get(
      'following/$userId',
      queryParameters: {'size': 1, 'page': 1},
    );
    final following = (followingRes.data['data']?['totalItems'] as int?) ?? 0;

    return FollowCounts(
      posts: posts,
      followers: followers,
      following: following,
    );
  }
}
