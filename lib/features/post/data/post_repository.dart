// lib/features/post/data/post_repository.dart
import '../domain/post_model.dart';
import '../domain/comment_model.dart';
import '../../../core/networks/api_client.dart';
import '../../../core/storage/token_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(ref.watch(apiClientProvider));
});

class PostRepository {
  final ApiClient _api;

  PostRepository(this._api);

  // ✅ Get explore posts
  Future<List<PostModel>> getExplorePosts({int page = 1, int size = 10}) async {
    final res = await _api.get('/explore-post', queryParameters: {
      'page': page,
      'size': size,
    });
    final data = res.data['data']['posts'] as List;
    return data.map((e) => PostModel.fromMap(e)).toList();
  }

  // ✅ Get following posts
  Future<List<PostModel>> getFeedPosts({int page = 1, int size = 10}) async {
    final res = await _api.get('/following-post', queryParameters: {
      'page': page,
      'size': size,
    });
    final data = res.data['data']['posts'] as List;
    return data.map((e) => PostModel.fromMap(e)).toList();
  }

  // 🆕 Get detail post
  Future<PostModel> getPostDetail(String postId) async {
    final res = await _api.get('/post/$postId');
    final data = res.data['data'];
    return PostModel.fromMap(data);
  }

  // 🆕 Like post
  Future<void> likePost(String postId) async {
    await _api.post('/like', data: {'postId': postId});
  }

  // 🆕 Unlike post
  Future<void> unlikePost(String postId) async {
    await _api.delete('/unlike/$postId');
  }
}
