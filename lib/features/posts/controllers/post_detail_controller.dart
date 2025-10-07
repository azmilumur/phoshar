import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/post_repository.dart';
import '../../posts/data/photo.dart';
import '../../posts/data/comment.dart';

/// ✅ Provider tanpa family — satu instance aja
final postDetailControllerProvider =
    AsyncNotifierProvider<PostDetailController, Photo?>(
      PostDetailController.new,
    );

/// ✅ Controller untuk detail post
class PostDetailController extends AsyncNotifier<Photo?> {
  late final PostsRepository _repo;

  @override
  Future<Photo?> build() async {
    _repo = ref.read(postsRepositoryProvider);
    // default-nya null karena belum di-load
    return null;
  }

  /// 🔄 Load detail post
  Future<void> loadPost(String postId) async {
    state = const AsyncLoading();
    try {
      final post = await _repo.getPostDetail(postId);
      state = AsyncData(post);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// ❤️ Like
  Future<void> likePost(String postId) async {
    try {
      await _repo.likePost(postId);
      final current = state.value;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            isLike: true,
            totalLikes: (current.totalLikes ?? 0) + 1,
          ),
        );
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// 💔 Unlike
  Future<void> unlikePost(String postId) async {
    try {
      await _repo.unlikePost(postId);
      final current = state.value;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            isLike: false,
            totalLikes: (current.totalLikes ?? 1) - 1,
          ),
        );
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// 💬 Tambah komentar
  Future<void> addComment(
    String postId,
    String comment, {
    void Function()? onSuccess,
  }) async {
    try {
      await _repo.addComment(postId, comment);

      final current = state.value;
      if (current != null) {
        final newComment = CommentModel(
          id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
          comment: comment,
          username: 'You',
          profilePictureUrl: '',
        );

        final updated = current.copyWith(
          comments: [...(current.comments ?? []), newComment],
        );

        state = AsyncData(updated);

        // ✅ Panggil animasi sukses di UI
        onSuccess?.call();
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // Hapus Komentar
  Future<void> deleteComment(String commentId) async {
    try {
      // Tunggu delete selesai di server
      await _repo.deleteComment(commentId);

      // Delay biar rebuild ga bentrok
      await Future.delayed(const Duration(milliseconds: 300));

      final current = state.value;
      if (current != null) {
        final updatedComments = current.comments
            ?.where((c) => c.id != commentId)
            .toList();

        // update state aman
        state = AsyncData(current.copyWith(comments: updatedComments));
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
