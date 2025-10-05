// lib/features/post/controllers/feed_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/post_repository.dart';
import '../domain/post_model.dart';

final feedControllerProvider =
    AsyncNotifierProvider<FeedController, List<PostModel>>(FeedController.new);

class FeedController extends AsyncNotifier<List<PostModel>> {
  late final PostRepository _repo;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  Future<List<PostModel>> build() async {
    _repo = ref.read(postRepositoryProvider);
    return _fetchPage(1);
  }

  Future<void> loadFeed() async {
    // buat refresh manual
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await _repo.getFeedPosts(page: 1, size: 10);
    });
  }

  Future<void> loadNextPage() async {
    if (!_hasMore) return;
    final nextPage = _currentPage + 1;
    final newPosts = await _fetchPage(nextPage);
    if (newPosts.isEmpty) {
      _hasMore = false;
      return;
    }
    _currentPage = nextPage;
    state = AsyncData([...state.value ?? [], ...newPosts]);
  }

  Future<List<PostModel>> _fetchPage(int page) async {
    try {
      final data = await _repo.getFeedPosts(page: page, size: 10);
      return data;
    } catch (e, st) {
      state = AsyncError(e, st);
      return [];
    }
  }

  Future<void> refreshFeed() async {
    state = const AsyncLoading();
    final newPosts = await _fetchPage(1);
    state = AsyncData(newPosts);
    _currentPage = 1;
  }
}
