import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:phoshar/features/posts/data/photo.dart';
import '../../features/posts/controllers/post_controller.dart';

class PostCard extends ConsumerStatefulWidget {
  final Photo post;

  const PostCard({super.key, required this.post});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool _isAnimating = false;
  bool _isLiked = false;
  int _totalLikes = 0;
  bool _isUnliking = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLike ?? false;
    _totalLikes = widget.post.totalLikes ?? 0;
  }

  Future<void> _toggleLike() async {
    final postId = widget.post.id;
    final repo = ref.read(postControllerProvider.notifier);

    // 💖 LIKE
    if (!_isLiked) {
      setState(() {
        _isLiked = true;
        _totalLikes++;
        _isAnimating = true;
      });

      await repo.likePost(postId);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _isAnimating = false);
    }
    // 💔 UNLIKE
    else {
      setState(() {
        _isLiked = false;
        _totalLikes = (_totalLikes > 0) ? _totalLikes - 1 : 0;
        _isUnliking = true;
      });

      await repo.unlikePost(postId);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _isUnliking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.post.user;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/post/${widget.post.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header user
            ListTile(
              leading: CircleAvatar(
                backgroundImage: (user?.profilePictureUrl?.isNotEmpty ?? false)
                    ? NetworkImage(user!.profilePictureUrl!)
                    : null,
                child: (user?.profilePictureUrl?.isEmpty ?? true)
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(user?.username ?? 'Unknown'),
              subtitle: Text(
                widget.post.createdAt != null
                    ? (widget.post.createdAt is String
                          ? (widget.post.createdAt as String).split('T').first
                          : (widget.post.createdAt as DateTime)
                                .toIso8601String()
                                .split('T')
                                .first)
                    : 'Unknown date',
              ),
            ),

            // 🔹 Gambar post
            if (widget.post.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.post.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 250,
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Icon(Icons.broken_image, size: 50)),
                ),
              )
            else
              const SizedBox(
                height: 150,
                child: Center(child: Icon(Icons.image_not_supported, size: 40)),
              ),

            const SizedBox(height: 8),

            // 🔹 Like button + count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: _toggleLike,
                        child: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? Colors.redAccent : Colors.grey,
                          size: 30,
                        ),
                      ),

                      // 💖 Lottie Like animation
                      if (_isAnimating)
                        Lottie.asset(
                          'assets/animations/like.json',
                          width: 80,
                          height: 80,
                          repeat: false,
                        ),

                      // 💔 Lottie Unlike animation
                      if (_isUnliking)
                        Lottie.asset(
                          'assets/animations/unlike.json',
                          width: 80,
                          height: 80,
                          repeat: false,
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_totalLikes suka',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
