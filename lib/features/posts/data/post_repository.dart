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

  // helper aman parse ISO -> DateTime utk sorting
  DateTime _parseIso(String? s) {
    if (s == null || s.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0); // paling tua
    }
    return DateTime.tryParse(s)?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  /// GET /api/v1/users-post/{userId}?page=&size=
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
    final posts = (map['data']?['posts'] as List?) ?? const <dynamic>[];

    final items =
        posts.map((e) => Photo.fromJson(e as Map<String, dynamic>)).toList()
          ..sort(
            (a, b) => _parseIso(b.createdAt).compareTo(_parseIso(a.createdAt)),
          );
    return items;
  }

  /// GET /api/v1/following-post?page=&size=
  Future<List<Photo>> getFollowing({int page = 1, int size = 12}) async {
    final res = await _dio.get(
      '/following-post',
      queryParameters: {'page': page, 'size': size},
    );
    final map = res.data as Map<String, dynamic>;
    final posts = (map['data']?['posts'] as List?) ?? const <dynamic>[];

    final items =
        posts.map((e) => Photo.fromJson(e as Map<String, dynamic>)).toList()
          ..sort(
            (a, b) => _parseIso(b.createdAt).compareTo(_parseIso(a.createdAt)),
          );
    return items;
  }
}
