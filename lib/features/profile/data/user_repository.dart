import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import 'user_profile.dart';

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

  /// Karena tidak ada endpoint detail user, header user lain kita fallback minimal.
  Future<UserProfile> getUserHeaderFallback(String userId) async {
    // kamu bisa kembangkan pakai endpoint lain kalau tersedia
    return UserProfile(id: userId, name: 'User', username: '', email: '');
  }

  /// POST /follow  { userIdFollow }
  Future<FollowResult> follow(String userId) async {
    try {
      await _dio.post('follow', data: {'userIdFollow': userId});
      return FollowResult.followed;
    } on DioException catch (e) {
      final d = e.response?.data;
      final status = (d is Map
          ? (d['status']?.toString().toUpperCase())
          : null);
      final msg = (d is Map && d['message'] is String)
          ? d['message'] as String
          : '';
      if (status == 'CONFLICT' ||
          msg.toLowerCase().contains('already follow')) {
        return FollowResult.alreadyFollowing;
      }
      rethrow;
    }
  }

  /// DELETE /unfollow/{userId}
  Future<void> unfollow(String userId) async {
    await _dio.delete('unfollow/$userId');
  }

  /// Counts untuk diri sendiri (pakai endpoint "my-")
  Future<FollowCounts> getMyCounts(String myId) async {
    // posts count
    final postsRes = await _dio.get(
      'users-post/$myId',
      queryParameters: {'size': 1, 'page': 1},
    );
    final posts = (postsRes.data['data']?['totalItems'] as int?) ?? 0;

    // followers & following
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

  /// Counts untuk user lain (pakai endpoint tanpa "my-")
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
