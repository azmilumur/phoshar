import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // 🧭 Arahkan ke detail page pakai GoRouter
        context.push('/post/${post.id}');
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrl.isNotEmpty)
              Image.network(
                post.imageUrl,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              )
            else
              Container(
                width: double.infinity,
                height: 220,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, size: 40),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.user?.username ?? 'Unknown user',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (post.caption.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      post.caption,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
