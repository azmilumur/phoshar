import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/networks/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/post_model.dart';
import '../domain/comment_model.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  final tokenStore = ref.watch(tokenStoreProvider);
  return PostRepository(api, tokenStore);
});

class PostRepository {
  final ApiClient _api;
  final TokenStore _tokens;

  PostRepository(this._api, this._tokens);

  // ✅ Get explore posts (with pagination)
  Future<List<PostModel>> getExplorePosts({int page = 1, int size = 10}) async {
    final res = await _api.get(
      '/explore-post',
      queryParameters: {'page': page, 'size': size},
    );

    final data = res.data['data']['posts'] as List;
    return data.map((e) => PostModel.fromMap(e)).toList();
  }

  // ✅ Get following posts (feed)
  Future<List<PostModel>> getFeedPosts({int page = 1, int size = 10}) async {
    final res = await _api.get(
      '/following-post',
      queryParameters: {'page': page, 'size': size},
    );

    final data = res.data['data']['posts'] as List;
    return data.map((e) => PostModel.fromMap(e)).toList();
  }

  // ✅ Get detail post by ID
  Future<PostModel> getPostDetail(String postId) async {
    final res = await _api.get('/post/$postId');
    final data = res.data['data'];
    return PostModel.fromMap(data);
  }

  // ❤️ Like post
  Future<void> likePost(String postId) async {
    final token = await _tokens.getAccessToken();
    final res = await _api.post(
      '/like',
      data: {'postId': postId},
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = res.data as Map<String, dynamic>;
    if (data['code'] != "200") {
      throw Exception(data['message'] ?? 'Gagal like post');
    }
  }

  // 💔 Unlike post
  Future<void> unlikePost(String postId) async {
    final token = await _tokens.getAccessToken();
    final res = await _api.post(
      '/unlike',
      data: {'postId': postId},
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = res.data as Map<String, dynamic>;
    if (data['code'] != "200") {
      throw Exception(data['message'] ?? 'Gagal unlike post');
    }
  }

  // 💬 Add comment
  Future<void> addComment(String postId, String comment) async {
    final token = await _tokens.getAccessToken();
    final res = await _api.post(
      '/create-comment',
      data: {'postId': postId, 'comment': comment},
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = res.data as Map<String, dynamic>;
    if (data['code'] != "200") {
      throw Exception(data['message'] ?? 'Gagal menambah komentar');
    }
  }

  // 🗑️ Delete comment
  Future<void> deleteComment(String commentId) async {
    final token = await _tokens.getAccessToken();
    final res = await _api.delete(
      '/delete-comment/$commentId',
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = res.data as Map<String, dynamic>;
    if (data['code'] != "200") {
      throw Exception(data['message'] ?? 'Gagal menghapus komentar');
    }
  }
}
