import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/post_repository.dart';
import '../domain/post_model.dart';

/// Provider untuk detail post
final postDetailControllerProvider =
    AsyncNotifierProvider<PostDetailController, PostModel?>(
  PostDetailController.new,
);

/// Controller untuk handle state detail post
class PostDetailController extends AsyncNotifier<PostModel?> {
  late final PostRepository _repo;

  @override
  Future<PostModel?> build() async {
    // default-nya belum ada data
    _repo = ref.read(postRepositoryProvider);
    return null;
  }

  /// Load detail post berdasarkan ID
  Future<void> loadPost(String postId) async {
    state = const AsyncLoading(); // set loading state
    try {
      final post = await _repo.getPostDetail(postId);
      state = AsyncData(post);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
