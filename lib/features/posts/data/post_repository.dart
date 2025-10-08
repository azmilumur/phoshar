// lib/features/posts/data/post_repository.dart
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/networks/dio_client.dart';
import 'photo.dart';

final postsRepositoryProvider = Provider<PostsRepository>(
  (ref) => PostsRepository(ref.watch(dioClientProvider)),
);

class PostsRepository {
  PostsRepository(this._dio);
  final Dio _dio;

  // --- helper: robust convert any to DateTime (buat sorting desc) ---
  DateTime _toDateTime(Object? v) {
    if (v is DateTime) return v.toUtc();
    if (v is String) {
      return DateTime.tryParse(v)?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  // ===================== LISTING =====================

  /// GET /users-post/{userId}?page=&size=
  Future<List<Photo>> getByUser(
    String userId, {
    int page = 1,
    int size = 12,
  }) async {
    final res = await _dio.get(
      'users-post/$userId',
      queryParameters: {'page': page, 'size': size},
    );
    final map = res.data as Map<String, dynamic>;
    final posts = (map['data']?['posts'] as List?) ?? const <dynamic>[];

    final items =
        posts.map((e) => Photo.fromJson(e as Map<String, dynamic>)).toList()
          ..sort(
            (a, b) =>
                _toDateTime(b.createdAt).compareTo(_toDateTime(a.createdAt)),
          );
    return items;
  }

  Future<List<Photo>> getTimeline({
    required String meId,
    required int page,
    required int size,
  }) async {
    // Ambil paralel biar cepat
    final results = await Future.wait<List<Photo>>([
      getFollowing(page: page, size: size),
      getByUser(meId, page: page, size: size),
    ]);

    // Gabungkan & de-dupe by id
    final map = <String, Photo>{};
    for (final p in [...results[0], ...results[1]]) {
      map[p.id] = p;
    }

    final merged = map.values.toList()
      ..sort(
        (a, b) => _toDateTime(b.createdAt).compareTo(_toDateTime(a.createdAt)),
      );

    // Batasi ke `size` biar konsisten
    if (merged.length > size) return merged.sublist(0, size);
    return merged;
  }

  /// GET /following-post?page=&size=
  Future<List<Photo>> getFollowing({int page = 1, int size = 12}) async {
    final res = await _dio.get(
      'following-post',
      queryParameters: {'page': page, 'size': size},
    );
    final map = res.data as Map<String, dynamic>;
    final posts = (map['data']?['posts'] as List?) ?? const <dynamic>[];

    final items =
        posts.map((e) => Photo.fromJson(e as Map<String, dynamic>)).toList()
          ..sort(
            (a, b) =>
                _toDateTime(b.createdAt).compareTo(_toDateTime(a.createdAt)),
          );
    return items;
  }

  // ===================== CREATE =====================

  /// POST /upload-image (form-data "image") -> return URL
  Future<String> uploadImage(XFile file) async {
    final Uint8List bytes = await file.readAsBytes();
    final form = FormData.fromMap({
      'image': MultipartFile.fromBytes(bytes, filename: file.name),
    });
    final res = await _dio.post('upload-image', data: form);
    final data = res.data as Map<String, dynamic>;
    final url = (data['url'] ?? data['data']?['url'])?.toString();
    if (url == null || url.isEmpty) {
      throw Exception('Upload image gagal: URL tidak ditemukan di response.');
    }
    return url;
  }

  /// POST /create-post  body: { imageUrl, caption }
  Future<void> createPost({
    required String imageUrl,
    required String caption,
  }) async {
    await _dio.post(
      'create-post',
      data: {'imageUrl': imageUrl, 'caption': caption},
    );
  }

  Future<List<Photo>> getExplorePosts({int page = 1, int size = 10}) async {
    final res = await _dio.get(
      'explore-post',
      queryParameters: {'page': page, 'size': size},
    );

    final data = res.data['data']['posts'] as List;
    return data.map((e) => Photo.fromJson(e)).toList();
  }

  Future<List<Photo>> getFeedPosts({int page = 1, int size = 10}) async {
    final res = await _dio.get(
      'following-post',
      queryParameters: {'page': page, 'size': size},
    );

    final data = res.data['data']['posts'] as List;
    return data.map((e) => Photo.fromJson(e)).toList();
  }

  Future<void> likePost(String postId) async {
    final res = await _dio.post('like', data: {'postId': postId});

    final data = res.data as Map<String, dynamic>;
    if (data['code'] != "200") {
      throw Exception(data['message'] ?? 'Gagal like post');
    }
  }

  Future<Photo> getPostDetail(String postId) async {
    final res = await _dio.get('post/$postId');
    final data = res.data['data'];
    return Photo.fromJson(data);
  }

  // 💔 Unlike post
  Future<void> unlikePost(String postId) async {
    final res = await _dio.post('unlike', data: {'postId': postId});

    final data = res.data as Map<String, dynamic>;
    if (data['code'] != "200") {
      throw Exception(data['message'] ?? 'Gagal unlike post');
    }
  }

  // 💬 Add comment
  Future<void> addComment(String postId, String comment) async {
    final res = await _dio.post(
      '/create-comment',
      data: {'postId': postId, 'comment': comment},
    );

    final data = res.data as Map<String, dynamic>;
    if (data['code'] != "200") {
      throw Exception(data['message'] ?? 'Gagal menambah komentar');
    }
  }

  // 🗑️ Delete comment
  Future<void> deleteComment(String commentId) async {
    final res = await _dio.delete('/delete-comment/$commentId');

    final data = res.data as Map<String, dynamic>;
    if (data['code'] != "200") {
      throw Exception(data['message'] ?? 'Gagal menghapus komentar');
    }
  }

  //// POST /api/v1/update-post/{postId}
  Future<void> updatePost({
    required String postId,
    required String imageUrl,
    required String caption,
  }) async {
    final res = await _dio.post(
      'update-post/$postId',
      data: {'imageUrl': imageUrl, 'caption': caption},
    );
    final data = res.data as Map<String, dynamic>;
    if (data['code']?.toString() != '200') {
      throw Exception(data['message'] ?? 'Gagal update post');
    }
  }

  /// DELETE /api/v1/delete-post/{postId}
  Future<void> deletePost(String postId) async {
    final res = await _dio.delete('delete-post/$postId');
    final data = res.data as Map<String, dynamic>;
    if (data['code']?.toString() != '200') {
      throw Exception(data['message'] ?? 'Gagal menghapus post');
    }
  }
}
