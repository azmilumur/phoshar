// lib/features/profile/presentation/profile_page.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/controllers/session_controller.dart'; // sessionControllerProvider
import '../../../core/networks/dio_client.dart'; // dioClientProvider
import '../../social/data/social_repository.dart'; // socialRepositoryProvider

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({
    super.key,
    required this.userId,
    this.initialIsFollowing,
    this.initialName,
    this.initialUsername,
    this.initialAvatarUrl,
    this.initialEmail,
  });

  final String userId;
  final bool? initialIsFollowing;
  final String? initialName;
  final String? initialUsername;
  final String? initialAvatarUrl;
  final String? initialEmail;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String? _name, _username, _avatarUrl, _email;
  bool _followBusy = false;
  bool _isFollowing = false;
  int followersCount = 0;
  int followingCount = 0;
  int postsCount = 0;

  final _photos = <_PhotoItem>[];
  final _scroll = ScrollController();
  static const _pageSize = 18;
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initialIsFollowing ?? false;
    _name = widget.initialName;
    _username = widget.initialUsername;
    _avatarUrl = widget.initialAvatarUrl;
    _email = widget.initialEmail;
    _scroll.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final me = ref.read(sessionControllerProvider).asData?.value;
      final isMe = me?.id == widget.userId;
      if (isMe) {
        setState(() {
          _name ??= me?.name ?? me?.username ?? 'Me';
          _username ??= me?.username;
          _avatarUrl ??= me?.profilePictureUrl;
          _email ??= me?.email;
        });
      }
      _loadCounts();
      _loadPosts(reset: true);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadCounts() async {
    final social = ref.read(socialRepositoryProvider);
    final dio = ref.read(dioClientProvider);

    try {
      final followers = await social.followersOf(widget.userId, page: 1, size: 1);
      final following = await social.followingOf(widget.userId, page: 1, size: 1);

      final res = await dio.get(
        'users-post/${widget.userId}',
        queryParameters: {'page': 1, 'size': 1},
      );
      final map = res.data as Map<String, dynamic>;
      final data = map['data'] as Map<String, dynamic>?;
      final totalPosts = (data?['totalItems'] as num?)?.toInt() ?? 0;

      if (!mounted) return;
      setState(() {
        followersCount = followers.totalItems;
        followingCount = following.totalItems;
        postsCount = totalPosts;
      });
    } catch (e) {
      _showErrorSnackbar('Gagal memuat data profil');
    }
  }

  Future<void> _loadPosts({bool reset = false}) async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      if (reset) {
        _page = 1;
        _hasMore = true;
      }

      final dio = ref.read(dioClientProvider);
      final res = await dio.get(
        'users-post/${widget.userId}',
        queryParameters: {'page': _page, 'size': _pageSize},
      );

      final map = res.data as Map<String, dynamic>;
      final data = map['data'] as Map<String, dynamic>?;
      final totalPages = (data?['totalPages'] as num?)?.toInt() ?? 1;
      final list = (data?['posts'] as List?) ?? const [];

      final items = list
          .whereType<Map>()
          .map((m) => _PhotoItem.fromMap(m.cast<String, dynamic>()))
          .toList()
        ..sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));

      if (!mounted) return;
      setState(() {
        if (_page == 1) {
          _photos
            ..clear()
            ..addAll(items);
        } else {
          _photos.addAll(items);
        }
        _hasMore = _page < totalPages;
        _page++;
      });
    } catch (e) {
      _showErrorSnackbar('Gagal memuat postingan');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onScroll() {
    if (_loading || !_hasMore) return;
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 480) {
      _loadPosts();
    }
  }

  Future<void> _refresh() async {
    await _loadCounts();
    await _loadPosts(reset: true);
  }

  Future<void> _toggleFollow() async {
    if (_followBusy) return;
    setState(() => _followBusy = true);

    final repo = ref.read(socialRepositoryProvider);
    try {
      if (_isFollowing) {
        final ok = await repo.unfollow(widget.userId);
        setState(() {
          _isFollowing = ok;
          followersCount = (followersCount - 1).clamp(0, 1 << 31);
        });
      } else {
        final ok = await repo.follow(widget.userId);
        setState(() {
          final was = _isFollowing;
          _isFollowing = ok;
          if (!was && _isFollowing) followersCount += 1;
        });
      }
    } catch (e) {
      _showErrorSnackbar('Gagal memproses follow/unfollow');
    } finally {
      if (mounted) setState(() => _followBusy = false);
    }
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.logout, color: Colors.red.shade400),
            ),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.red.shade600],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(sessionControllerProvider.notifier).signOut();
      if (mounted) context.go('/login');
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(sessionControllerProvider).asData?.value;
    final isMe = me?.id == widget.userId;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          _username != null && _username!.isNotEmpty ? '@$_username' : 'Profile',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          if (isMe)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[700]),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (value) async {
                if (value == 'logout') {
                  await _showLogoutDialog();
                }
                if (value == 'edit') {
                  context.push('/profile/edit');
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 12),
                      Text('Edit Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.redAccent),
                      SizedBox(width: 12),
                      Text('Logout', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          controller: _scroll,
          children: [
            // Header Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar & Info
                  Row(
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 39,
                            backgroundImage: (_avatarUrl != null &&
                                    _avatarUrl!.isNotEmpty)
                                ? NetworkImage(_avatarUrl!)
                                : null,
                            child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _name ?? 'User',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (_username != null && _username!.isNotEmpty)
                              Text(
                                '@$_username',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              )
                            else if (_email != null && _email!.isNotEmpty)
                              Text(
                                _email!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          value: postsCount,
                          label: 'Posts',
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      Expanded(
                        child: _StatBox(
                          value: followersCount,
                          label: 'Followers',
                          onTap: () =>
                              context.go('/users/${widget.userId}/followers'),
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      Expanded(
                        child: _StatBox(
                          value: followingCount,
                          label: 'Following',
                          onTap: () =>
                              context.go('/users/${widget.userId}/following'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Action Button
                  if (isMe)
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.push('/profile/edit'),
                          borderRadius: BorderRadius.circular(12),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_outlined, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Edit Profile',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isFollowing
                              ? [Colors.grey.shade400, Colors.grey.shade600]
                              : [
                                  Colors.purple.shade400,
                                  Colors.pink.shade400
                                ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (_isFollowing
                                    ? Colors.grey
                                    : Colors.purple)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _followBusy ? null : _toggleFollow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _followBusy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _isFollowing
                                    ? Icons.person_remove_outlined
                                    : Icons.person_add_outlined,
                                color: Colors.white,
                              ),
                        label: Text(
                          _isFollowing ? 'Unfollow' : 'Follow',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Grid Section
            if (_photos.isEmpty && !_loading)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada postingan',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _photos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemBuilder: (context, index) {
                  final p = _photos[index];
                  return GestureDetector(
                    onTap: () {
                      if (isMe) {
                        context.go('/my-posts', extra: {'initialIndex': index});
                      } else {
                        context.go(
                          '/users/${widget.userId}/posts',
                          extra: {'initialIndex': index},
                        );
                      }
                    },
                    child: Container(
                      color: Colors.grey[200],
                      child: Image.network(
                        p.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey[400],
                          ),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),

            if (_loading && _photos.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.purple.shade400,
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Helper widgets
class _PhotoItem {
  final String id;
  final String imageUrl;
  final String? caption;
  final DateTime? createdAt;

  const _PhotoItem({
    required this.id,
    required this.imageUrl,
    this.caption,
    this.createdAt,
  });

  factory _PhotoItem.fromMap(Map<String, dynamic> m) => _PhotoItem(
        id: (m['id'] ?? '').toString(),
        imageUrl: (m['imageUrl'] ?? '').toString(),
        caption: m['caption'] as String?,
        createdAt: m['createdAt'] != null
            ? DateTime.tryParse(m['createdAt'].toString())
            : null,
      );
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    this.onTap,
  });

  final int value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

