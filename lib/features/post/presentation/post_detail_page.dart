// lib/features/post/presentation/post_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/post_detail_controller.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_empty_state.dart';

class PostDetailPage extends ConsumerStatefulWidget {
  final String postId;
  const PostDetailPage({super.key, required this.postId});

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  @override
  void initState() {
    super.initState();

    // ✅ panggil setelah frame selesai build
    Future.microtask(() {
      ref.read(postDetailControllerProvider.notifier).loadPost(widget.postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postDetailControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Post Detail')),
      body: state.when(
        loading: () => const AppLoading(),
        error:
            (e, _) => AppError(
              message: e.toString(),
              onRetry: () {
                ref
                    .read(postDetailControllerProvider.notifier)
                    .loadPost(widget.postId);
              },
            ),
        data: (post) {
          if (post == null) {
            return const AppEmptyState(message: 'Post not found');
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(post.imageUrl),
                  ),
                const SizedBox(height: 12),
                Text(
                  post.caption.isNotEmpty ? post.caption : '(no caption)',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text('${post.totalLikes} likes'),
                const Divider(height: 32),
                const Text(
                  'Comments',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...(post.comments ?? []).map((c) {
                  final hasImage = (c.profilePictureUrl ?? '').isNotEmpty;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          hasImage ? NetworkImage(c.profilePictureUrl!) : null,
                      child: !hasImage ? const Icon(Icons.person) : null,
                    ),
                    title: Text(c.username),
                    subtitle: Text(c.comment),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
