import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/post_repository.dart';
import '../domain/post_model.dart';

final postControllerProvider = AsyncNotifierProvider<PostController, List<PostModel>>(
  PostController.new,
);

class PostController extends AsyncNotifier<List<PostModel>> {
  late final PostRepository _repo;

  @override
  Future<List<PostModel>> build() async {
    _repo = ref.read(postRepositoryProvider);
    return [];
  }

  Future<void> loadExplorePosts() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.getExplorePosts());
  }

  Future<void> loadFeedPosts() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.getFeedPosts());
  }
}
