import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../data/post_repository.dart';

final updatePostControllerProvider =
    AsyncNotifierProvider.autoDispose<UpdatePostController, void>(
      UpdatePostController.new,
    );

class UpdatePostController extends AsyncNotifier<void> {
  late final PostsRepository _repo;

  @override
  Future<void> build() async {
    _repo = ref.read(postsRepositoryProvider);
  }

  /// Jika [newImage] null → pakai [currentImageUrl].
  Future<void> submit({
    required String postId,
    required String currentImageUrl,
    required String caption,
    XFile? newImage,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      String finalUrl = currentImageUrl;
      if (newImage != null) {
        finalUrl = await _repo.uploadImage(newImage);
      }
      await _repo.updatePost(
        postId: postId,
        imageUrl: finalUrl,
        caption: caption,
      );
    });
  }
}
