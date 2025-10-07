// lib/features/post/presentation/post_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:phoshar/features/auth/controllers/auth_controller.dart';
import '../controllers/post_detail_controller.dart';

class PostDetailPage extends ConsumerStatefulWidget {
  final String postId;
  const PostDetailPage({super.key, required this.postId});

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final TextEditingController _commentCtrl = TextEditingController();

  static const _animationDuration = Duration(seconds: 2);
  static const _animationSize = 180.0;

  void _showLottie(String file) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        Future.delayed(_animationDuration, () {
          if (ctx.mounted) Navigator.of(ctx).pop();
        });
        return Center(
          child: Lottie.asset(
            'assets/animations/$file.json',
            width: _animationSize,
            height: _animationSize,
            repeat: false,
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteComment(
    BuildContext context,
    WidgetRef ref,
    String commentId,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Hapus Komentar?'),
            content: const Text('Yakin ingin menghapus komentar ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (shouldDelete != true) return;

    try {
      await ref
          .read(postDetailControllerProvider.notifier)
          .deleteComment(commentId);
      _showLottie('success');
    } catch (_) {
      _showLottie('failed');
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(postDetailControllerProvider.notifier).loadPost(widget.postId);
    });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(postDetailControllerProvider);
    final authUser = ref.watch(authControllerProvider).asData?.value;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Post Detail',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: postAsync.when(
        data: (post) {
          if (post == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🎨 Post Card
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 👤 Header user
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.purple.shade300,
                                          Colors.pink.shade300,
                                        ],
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: CircleAvatar(
                                      radius: 26,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 24,
                                        backgroundImage:
                                            (post
                                                        .user
                                                        ?.profilePictureUrl
                                                        ?.isNotEmpty ??
                                                    false)
                                                ? NetworkImage(
                                                  post.user!.profilePictureUrl!,
                                                )
                                                : null,
                                        child:
                                            (post
                                                        .user
                                                        ?.profilePictureUrl
                                                        ?.isEmpty ??
                                                    true)
                                                ? const Icon(Icons.person)
                                                : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.user?.username ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Just now',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),

                            // 🖼️ Image
                            if (post.imageUrl.isNotEmpty)
                              Hero(
                                tag: 'post-${post.id}',
                                child: Image.network(
                                  post.imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, progress) =>
                                          progress == null
                                              ? child
                                              : Container(
                                                height: 300,
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              ),
                                ),
                              ),

                            // ❤️ Like bar
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      post.isLike
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color:
                                          post.isLike
                                              ? Colors.redAccent
                                              : Colors.grey[700],
                                      size: 28,
                                    ),
                                    onPressed: () async {
                                      final ctrl = ref.read(
                                        postDetailControllerProvider.notifier,
                                      );
                                      if (post.isLike) {
                                        await ctrl.unlikePost(post.id);
                                      } else {
                                        await ctrl.likePost(post.id);
                                      }
                                    },
                                  ),
                                  Text(
                                    '${post.totalLikes ?? 0} likes',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Caption
                            if (post.caption.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            '${post.user?.username ?? 'User'} ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(text: post.caption),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // 💬 Comment section
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child:
                            post.comments?.isEmpty ?? true
                                ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline,
                                          size: 48,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Belum ada komentar',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: post.comments!.length,
                                  itemBuilder: (context, index) {
                                    final c = post.comments![index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey[200]!,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundImage:
                                                (c
                                                            .profilePictureUrl
                                                            ?.isNotEmpty ??
                                                        false)
                                                    ? NetworkImage(
                                                      c.profilePictureUrl!,
                                                    )
                                                    : null,
                                            child:
                                                (c.profilePictureUrl?.isEmpty ??
                                                        true)
                                                    ? const Icon(
                                                      Icons.person,
                                                      size: 18,
                                                    )
                                                    : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  c.username,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(c.comment),
                                              ],
                                            ),
                                          ),
                                          if (authUser != null &&
                                              c.username == authUser.username)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.redAccent,
                                                size: 20,
                                              ),
                                              onPressed:
                                                  () => _confirmDeleteComment(
                                                    context,
                                                    ref,
                                                    c.id,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
              ),

              // ✏️ Add comment
              _buildCommentInput(ref),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, _) => Center(
              child: Text(
                'Error: $err',
                style: const TextStyle(color: Colors.red),
              ),
            ),
      ),
    );
  }

  Widget _buildCommentInput(WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tulis komentar...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  onPressed: () async {
                    final text = _commentCtrl.text.trim();
                    if (text.isEmpty) return;
                    try {
                      await ref
                          .read(postDetailControllerProvider.notifier)
                          .addComment(widget.postId, text);
                      _commentCtrl.clear();
                      _showLottie('success');
                    } catch (_) {
                      _showLottie('failed');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
