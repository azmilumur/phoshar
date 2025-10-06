import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/controllers/session_controller.dart'; // AuthUser? me
import '../../../core/network/dio_client.dart'; // dioClientProvider
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

  /// user yang sedang dilihat (wajib)
  final String userId;

  /// seed status following (opsional)
  final bool? initialIsFollowing;

  /// seed header (opsional, berguna saat navigate dari list user)
  final String? initialName;
  final String? initialUsername;
  final String? initialAvatarUrl;
  final String? initialEmail;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  // ------- header dynamic -------
  String? _name, _username, _avatarUrl, _email;

  // ------- follow/unfollow -------
  bool _followBusy = false;
  bool _isFollowing = false;

  // ------- counters -------
  int followersCount = 0;
  int followingCount = 0;
  int postsCount = 0;

  // ------- grid & pagination -------
  final _photos = <_PhotoItem>[];
  final _scroll = ScrollController();
  static const _pageSize = 18;
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();

    // seed dari extra
    _isFollowing = widget.initialIsFollowing ?? false;
    _name = widget.initialName;
    _username = widget.initialUsername;
    _avatarUrl = widget.initialAvatarUrl;
    _email = widget.initialEmail;

    _scroll.addListener(_onScroll);

    // isi header untuk profil sendiri (fallback dari session)
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

  // ================= LOADERS =================

  Future<void> _loadCounts() async {
    final dio = ref.read(dioClientProvider);
    final social = ref.read(socialRepositoryProvider);

    try {
      // followers & following => gunakan totalItems dari endpoint list
      final followers = await social.followersOf(
        widget.userId,
        page: 1,
        size: 1,
      );
      final following = await social.followingOf(
        widget.userId,
        page: 1,
        size: 1,
      );

      // posts count => dari users-post
      final res = await dio.get(
        'users-post/${widget.userId}',
        queryParameters: {'page': 1, 'size': 1},
      );
      final data = (res.data?['data'] as Map<String, dynamic>?);
      final totalPosts = (data?['totalItems'] as num?)?.toInt() ?? 0;

      if (!mounted) return;
      setState(() {
        followersCount = followers.totalItems;
        followingCount = following.totalItems;
        postsCount = totalPosts;
      });
    } on DioException catch (e) {
      _toast(e.response?.data?['message']?.toString() ?? e.message ?? 'Error');
    } catch (e) {
      _toast('Gagal memuat ringkasan: $e');
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

      final data = (res.data?['data'] as Map<String, dynamic>?);
      final totalPages = (data?['totalPages'] as num?)?.toInt() ?? 1;
      final list = (data?['posts'] as List?) ?? const [];

      final items = list
          .whereType<Map>()
          .map((m) => _PhotoItem.fromMap(m.cast<String, dynamic>()))
          .toList();

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
    } on DioException catch (e) {
      _toast(e.response?.data?['message']?.toString() ?? e.message ?? 'Error');
    } catch (e) {
      _toast('Gagal memuat postingan: $e');
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

  // ================= ACTIONS =================

  Future<void> _toggleFollow() async {
    if (_followBusy) return;
    setState(() => _followBusy = true);

    final repo = ref.read(socialRepositoryProvider);
    try {
      if (_isFollowing) {
        final ok = await repo.unfollow(widget.userId);
        setState(() {
          _isFollowing = ok; // false
          followersCount = (followersCount - 1).clamp(0, 1 << 31);
        });
      } else {
        final ok = await repo.follow(widget.userId);
        setState(() {
          final was = _isFollowing;
          _isFollowing = ok; // true (juga true kalau "already follow")
          if (!was && _isFollowing) followersCount += 1;
        });
      }
    } catch (e) {
      _toast('Gagal memproses: $e');
    } finally {
      if (mounted) setState(() => _followBusy = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(sessionControllerProvider).asData?.value;
    final isMe = me?.id == widget.userId;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage:
                      (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                      ? NetworkImage(_avatarUrl!)
                      : null,
                  child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 32)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name ?? 'User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_username != null && _username!.isNotEmpty)
                        Text('@$_username')
                      else if (_email != null && _email!.isNotEmpty)
                        Text(_email!),
                    ],
                  ),
                ),
                if (isMe)
                  OutlinedButton.icon(
                    onPressed: () {
                      /* TODO: edit profile */
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                  )
                else
                  FilledButton.tonalIcon(
                    onPressed: _followBusy ? null : _toggleFollow,
                    icon: _followBusy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _isFollowing
                                ? Icons.person_remove
                                : Icons.person_add,
                          ),
                    label: Text(_isFollowing ? 'Unfollow' : 'Follow'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CountBox(value: postsCount, label: 'Posts'),
                _CountBox(
                  value: followersCount,
                  label: 'Followers',
                  onTap: () => context.go('/users/${widget.userId}/followers'),
                ),
                _CountBox(
                  value: followingCount,
                  label: 'Following',
                  onTap: () => context.go('/users/${widget.userId}/following'),
                ),
              ],
            ),

            const Divider(height: 32),

            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _photos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
              ),
              itemBuilder: (context, index) {
                final p = _photos[index];
                return InkWell(
                  onTap: () {
                    final me = ref
                        .read(sessionControllerProvider)
                        .asData
                        ?.value;
                    final isMe = me?.id == widget.userId;

                    // Buka feed “posts by user” dan mulai dari foto yang diketuk
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
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).dividerColor.withOpacity(.2),
                          width: .6,
                        ),
                        left: BorderSide(
                          color: Theme.of(context).dividerColor.withOpacity(.2),
                          width: .6,
                        ),
                      ),
                    ),
                    child: Image.network(
                      p.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Center(
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                );
              },
            ),

            if (_loading && _photos.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!_loading && _photos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: Text('Belum ada postingan')),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ================= helpers =================

class _PhotoItem {
  final String id;
  final String imageUrl;
  final String? caption;
  final DateTime? createdAt; // <— TAMBAH

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

class _CountBox extends StatelessWidget {
  const _CountBox({required this.value, required this.label, this.onTap});
  final int value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(label),
      ],
    );
    return InkWell(
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(8), child: child),
    );
  }
}
