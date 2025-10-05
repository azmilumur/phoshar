import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/post_repository.dart';
import '../domain/post_model.dart';

final exploreControllerProvider =
    AsyncNotifierProvider<ExploreController, List<PostModel>>(ExploreController.new);

class ExploreController extends AsyncNotifier<List<PostModel>> {
  late final PostRepository _repo;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  Future<List<PostModel>> build() async {
    _repo = ref.read(postRepositoryProvider);
    return _fetchPage(1);
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
      final data = await _repo.getExplorePosts(page: page, size: 10);
      return data;
    } catch (e, st) {
      state = AsyncError(e, st);
      return [];
    }
  }
}
