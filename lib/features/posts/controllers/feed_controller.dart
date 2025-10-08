// lib/features/posts/controllers/feed_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/session_controller.dart';
import '../data/post_repository.dart';
import '../data/photo.dart';

final feedControllerProvider =
    AsyncNotifierProvider<FeedController, List<Photo>>(FeedController.new);

class FeedController extends AsyncNotifier<List<Photo>> {
  late final PostsRepository _repo;
  static const _pageSize = 12;

  String? _meId;
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;

  @override
  Future<List<Photo>> build() async {
    _repo = ref.read(postsRepositoryProvider);
    _meId = ref.read(sessionControllerProvider).asData?.value?.id;

    if (_meId == null) return [];
    final first = await _repo.getTimeline(
      meId: _meId!,
      page: 1,
      size: _pageSize,
    );

    _hasMore = first.length >= _pageSize;
    _page = 2;
    return first;
  }

  Future<void> refreshFeed() async {
    if (_meId == null) return;
    state = const AsyncLoading();
    try {
      final fresh = await _repo.getTimeline(
        meId: _meId!,
        page: 1,
        size: _pageSize,
      );
      _hasMore = fresh.length >= _pageSize;
      _page = 2;
      state = AsyncData(fresh);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> loadNextPage() async {
    if (_meId == null || !_hasMore || _loadingMore) return;
    _loadingMore = true;
    final current = state.value ?? [];
    try {
      final next = await _repo.getTimeline(
        meId: _meId!,
        page: _page,
        size: _pageSize,
      );
      _hasMore = next.length >= _pageSize;
      _page++;
      state = AsyncData([...current, ...next]);
    } catch (e, st) {
      state = AsyncError(e, st);
    } finally {
      _loadingMore = false;
    }
  }
}
