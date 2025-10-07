import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/post_repository.dart';
import '../domain/post_model.dart';

/// Provider utama untuk handle semua operasi post (Explore, Feed, Like, dll)
final postControllerProvider =
    AsyncNotifierProvider<PostController, List<PostModel>>(PostController.new);

class PostController extends AsyncNotifier<List<PostModel>> {
  late final PostRepository _repo;

  // 🔢 Pagination state
  int _page = 1;
  bool _hasMore = true;
  bool _isLoading = false;

  @override
  Future<List<PostModel>> build() async {
    _repo = ref.read(postRepositoryProvider);
    // Saat pertama kali dibuka, tampilkan list kosong dulu
    return [];
  }

  /// 🚀 Load data pertama kali untuk halaman Explore
  Future<void> loadExplorePosts({int page = 1, int size = 30}) async {
    if (_isLoading) return;
    _isLoading = true;

    state = const AsyncLoading();

    try {
      final posts = await _repo.getExplorePosts(page: page, size: size);
      _page = 1;
      _hasMore = posts.length >= size;
      state = AsyncData(posts);

      print('📸 [Explore] loaded page $_page (${posts.length} posts)');
    } catch (e, st) {
      print('⚠️ [Explore] loadExplorePosts error: $e');
      state = AsyncError(e, st);
    } finally {
      _isLoading = false;
    }
  }

  /// 🔁 Load lebih banyak data (infinite scroll)
  Future<void> loadMoreExplorePosts({int size = 30}) async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;

    final current = state.value ?? [];
    final nextPage = _page + 1;

    try {
      final newPosts = await _repo.getExplorePosts(page: nextPage, size: size);

      if (newPosts.isEmpty) {
        _hasMore = false;
        print('🛑 [Explore] no more data after page $_page');
      } else {
        _page = nextPage;
        _hasMore = newPosts.length >= size;
        state = AsyncData([...current, ...newPosts]);
        print('📄 [Explore] loaded page $_page (${newPosts.length} posts)');
      }
    } catch (e, st) {
      print('⚠️ [Explore] loadMoreExplorePosts error: $e');
      state = AsyncError(e, st);
    } finally {
      _isLoading = false;
    }
  }

  /// 🔃 Refresh data Explore dari awal
  Future<void> refreshExplorePosts({int size = 30}) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final posts = await _repo.getExplorePosts(page: 1, size: size);
      _page = 1;
      _hasMore = posts.length >= size;
      state = AsyncData(posts);

      print('🔄 [Explore] refreshed page 1 (${posts.length} posts)');
    } catch (e, st) {
      print('⚠️ [Explore] refreshExplorePosts error: $e');
      state = AsyncError(e, st);
    } finally {
      _isLoading = false;
    }
  }

  /// 🏠 Load Feed (Following)
  Future<void> loadFeedPosts() async {
    if (_isLoading) return;
    _isLoading = true;

    state = const AsyncLoading();

    try {
      final posts = await _repo.getFeedPosts();
      state = AsyncData(posts);

      print('🏠 [Feed] loaded ${posts.length} posts');
    } catch (e, st) {
      print('⚠️ [Feed] loadFeedPosts error: $e');
      state = AsyncError(e, st);
    } finally {
      _isLoading = false;
    }
  }

  /// ❤️ Like a post
  Future<void> likePost(String postId) async {
    try {
      await _repo.likePost(postId);

      final current = state.value;
      if (current != null) {
        final updated = current.map((p) {
          if (p.id == postId) {
            return p.copyWith(
              isLike: true,
              totalLikes: (p.totalLikes ?? 0) + 1,
            );
          }
          return p;
        }).toList();

        state = AsyncData(updated);
        print('❤️ [Post] liked: $postId');
      }
    } catch (e) {
      print('⚠️ [Post] likePost error: $e');
    }
  }

  /// 💔 Unlike a post
  Future<void> unlikePost(String postId) async {
    try {
      await _repo.unlikePost(postId);

      final current = state.value;
      if (current != null) {
        final updated = current.map((p) {
          if (p.id == postId) {
            return p.copyWith(
              isLike: false,
              totalLikes: (p.totalLikes ?? 1) - 1,
            );
          }
          return p;
        }).toList();

        state = AsyncData(updated);
        print('💔 [Post] unliked: $postId');
      }
    } catch (e) {
      print('⚠️ [Post] unlikePost error: $e');
    }
  }

  /// Getter untuk cek apakah masih bisa load lagi
  bool get hasMore => _hasMore;
}
