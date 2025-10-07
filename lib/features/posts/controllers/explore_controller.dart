import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/post_repository.dart';
import '../data/photo.dart';

final exploreControllerProvider =
    AsyncNotifierProvider<ExploreController, List<Photo>>(
      ExploreController.new,
    );

class ExploreController extends AsyncNotifier<List<Photo>> {
  late final PostsRepository _repo;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingNext = false;

  @override
  Future<List<Photo>> build() async {
    _repo = ref.read(postsRepositoryProvider);
    return _fetchPage(1);
  }

  Future<List<Photo>> _fetchPage(int page) async {
    final data = await _repo.getExplorePosts(page: page, size: 30);
    if (data.isEmpty) _hasMore = false;
    return data;
  }

  Future<void> loadNextPage() async {
    if (_isLoadingNext || !_hasMore) return;
    _isLoadingNext = true;
    final nextPage = _currentPage + 1;
    final newPosts = await _fetchPage(nextPage);

    if (newPosts.isNotEmpty) {
      _currentPage = nextPage;
      state = AsyncData([...state.value ?? [], ...newPosts]);
    } else {
      _hasMore = false;
    }

    _isLoadingNext = false;
  }
}
