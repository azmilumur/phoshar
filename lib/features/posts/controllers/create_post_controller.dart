// import yang benar
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/post_repository.dart';
import 'package:image_picker/image_picker.dart';

// Provider
final createPostControllerProvider =
    AsyncNotifierProvider<CreatePostController, void>(CreatePostController.new);

class CreatePostController extends AsyncNotifier<void> {
  late PostsRepository _repo;

  @override
  FutureOr<void> build() {
    _repo = ref.read(postsRepositoryProvider);
  }

  Future<void> submit({required XFile image, required String caption}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final url = await _repo.uploadImage(image);
      await _repo.createPost(imageUrl: url, caption: caption);
    });
  }
}
