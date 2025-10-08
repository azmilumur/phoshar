// lib/features/post/presentation/post_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../auth/controllers/session_controller.dart'; // sessionControllerProvider
import '../../posts/controllers/post_detail_controller.dart'; // postDetailControllerProvider

class PostDetailPage extends ConsumerStatefulWidget {
  final String postId;
  const PostDetailPage({super.key, required this.postId});

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final _commentCtrl = TextEditingController();

  static const _animDur = Duration(seconds: 2);
  static const _animSize = 180.0;

  void _showLottie(String file) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        Future.delayed(_animDur, () {
          if (ctx.mounted) Navigator.of(ctx).pop();
        });
        return Center(
          child: Lottie.asset(
            'assets/animations/$file.json',
            width: _animSize,
            height: _animSize,
            repeat: false,
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteComment(String commentId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Komentar?'),
        content: const Text('Yakin ingin menghapus komentar ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;

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
    final me = ref.watch(sessionControllerProvider).asData?.value;

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

          final liked = post.isLike ?? false;
          final totalLikes = post.totalLikes ?? 0;
          final caption = (post.caption ?? '').trim();

          bool canDeleteComment(String cUsername) {
            final myUsername = me?.username ?? me?.email.split('@').first;
            return myUsername != null && cUsername == myUsername;
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ====== POST CARD ======
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
                            // HEADER USER (tappable ke profile)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: InkWell(
                                onTap: () {
                                  final u = post.user;
                                  if (u == null) return;

                                  final myId = me?.id;
                                  if (myId != null && myId == u.id) {
                                    // profil sendiri
                                    context.push('/profile');
                                  } else {
                                    // profil orang lain + SEED header via `extra`
                                    context.push(
                                      '/profile/${u.id}',
                                      extra: {
                                        'username': u
                                            .username, // tampilkan sebagai title
                                        'name': u
                                            .username, // kalau tidak punya name, pakai username
                                        'avatarUrl':
                                            u.profilePictureUrl, // url avatar
                                        'email': u.email, // fallback subtitle
                                        // 'isFollowing': true/false,        // opsional kalau kamu tahu statusnya
                                      },
                                    );
                                  }
                                },
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
                            ),

                            // IMAGE
                            if (post.imageUrl.isNotEmpty)
                              Hero(
                                tag: 'post-${post.id}',
                                child: Image.network(
                                  post.imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 300,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.broken_image_outlined),
                                    ),
                                  ),
                                  loadingBuilder: (context, child, progress) =>
                                      progress == null
                                      ? child
                                      : Container(
                                          height: 300,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                ),
                              ),

                            // LIKE BAR
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      liked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: liked
                                          ? Colors.redAccent
                                          : Colors.grey[700],
                                      size: 28,
                                    ),
                                    onPressed: () async {
                                      final ctrl = ref.read(
                                        postDetailControllerProvider.notifier,
                                      );
                                      try {
                                        if (liked) {
                                          await ctrl.unlikePost(post.id);
                                        } else {
                                          await ctrl.likePost(post.id);
                                        }
                                      } catch (_) {}
                                    },
                                  ),
                                  Text(
                                    '$totalLikes likes',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // CAPTION
                            if (caption.isNotEmpty)
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
                                      TextSpan(text: caption),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // ====== COMMENTS ======
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: (post.comments?.isEmpty ?? true)
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
                                        if (canDeleteComment(c.username))
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                _confirmDeleteComment(c.id),
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

              // ====== ADD COMMENT ======
              _buildCommentInput(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
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
