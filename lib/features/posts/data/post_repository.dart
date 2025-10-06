// lib/features/posts/data/post_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import 'photo.dart';

final postsRepositoryProvider = Provider<PostsRepository>(
  (ref) => PostsRepository(ref.watch(dioClientProvider)),
);

class PostsRepository {
  PostsRepository(this._dio);
  final Dio _dio;

  /// GET /users-post/{userId}?page=&size=
  Future<List<Photo>> getByUser(
    String userId, {
    int page = 1,
    int size = 12,
  }) async {
    final res = await _dio.get(
      '/users-post/$userId',
      queryParameters: {'page': page, 'size': size},
    );

    final map = res.data as Map<String, dynamic>;
    final data = (map['data'] as Map<String, dynamic>?) ?? const {};
    final posts = (data['posts'] as List?) ?? const [];

    final items =
        posts.map((e) => Photo.fromJson(e as Map<String, dynamic>)).toList()
          ..sort(
            (a, b) => b.createdAtEpoch.compareTo(a.createdAtEpoch),
          ); // DESC

    return items;
  }

  /// GET /following-post?page=&size=
  Future<List<Photo>> getFollowing({int page = 1, int size = 12}) async {
    final res = await _dio.get(
      '/following-post',
      queryParameters: {'page': page, 'size': size},
    );

    final map = res.data as Map<String, dynamic>;
    final data = (map['data'] as Map<String, dynamic>?) ?? const {};
    final posts = (data['posts'] as List?) ?? const [];

    final items =
        posts.map((e) => Photo.fromJson(e as Map<String, dynamic>)).toList()
          ..sort(
            (a, b) => b.createdAtEpoch.compareTo(a.createdAtEpoch),
          ); // DESC

    return items;
  }
}
