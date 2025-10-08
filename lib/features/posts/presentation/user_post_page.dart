// lib/features/posts/presentation/users_posts_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/post_repository.dart';
import '../data/photo.dart';
import '../../auth/controllers/session_controller.dart';

class UsersPostsPage extends ConsumerStatefulWidget {
  const UsersPostsPage({
    super.key,
    required this.userId,
    this.title,
    this.initialIndex,
    this.pageSize,
  });

  final String userId;
  final String? title;

  /// 0 = post terbaru
  final int? initialIndex;
  final int? pageSize;

  @override
  ConsumerState<UsersPostsPage> createState() => _UsersPostsPageState();
}

class _UsersPostsPageState extends ConsumerState<UsersPostsPage> {
  static const _defaultSize = 10;

  late final int _size;
  final _scroll = ScrollController();

  // data
  final _items = <Photo>[];

  // paging state
  int _page = 1;
  bool _firstLoad = true; // loading awal
  bool _loading = false; // loading API umum
  bool _isLoadingMore = false; // spinner bawah
  bool _hasMore = true;
  String? _error;

  // auto-jump ke initialIndex
  int? _targetIndex;
  bool _jumped = false;
  final _targetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _size = widget.pageSize ?? _defaultSize;
    _targetIndex = widget.initialIndex;

    _scroll.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _load(reset: true);
      if (_targetIndex != null) {
        await _loadUntilTarget();
        _tryJumpToTarget();
      }
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  // ================== LOADERS ==================

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _firstLoad = true;
        _page = 1;
        _hasMore = true;
        _items.clear();
        _jumped = false;
      }
    });

    try {
      final repo = ref.read(postsRepositoryProvider);
      final list = await repo.getByUser(
        widget.userId,
        page: _page,
        size: _size,
      );

      if (!mounted) return;
      setState(() {
        _items.addAll(list);
        _hasMore = list.length == _size;
        _page++;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _firstLoad = false;
      });
    }
  }

  Future<void> _loadUntilTarget() async {
    if (_targetIndex == null) return;
    while (mounted &&
        !_jumped &&
        _hasMore &&
        _items.length <= _targetIndex! &&
        !_loading) {
      await _load();
    }
  }

  Future<void> _refresh() async {
    await _load(reset: true);
    if (_targetIndex != null) {
      await _loadUntilTarget();
      _tryJumpToTarget();
    }
  }

  void _onScroll() async {
    if (_loading || !_hasMore) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      setState(() => _isLoadingMore = true);
      await _load();
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _tryJumpToTarget() {
    if (_jumped || _targetIndex == null) return;
    if (_targetIndex! >= _items.length) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _targetKey.currentContext;
      if (ctx != null) {
        _jumped = true;
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 1), // instan
          alignment: 0.1,
        );
      }
    });
  }

  String _timeAgo(DateTime? t) {
    if (t == null) return '';
    final d = DateTime.now().difference(t);
    if (d.inDays >= 1) return '${d.inDays}d';
    if (d.inHours >= 1) return '${d.inHours}h';
    if (d.inMinutes >= 1) return '${d.inMinutes}m';
    return 'now';
  }

  // ================== UI ==================

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(sessionControllerProvider).asData?.value;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.pink.shade400],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              widget.title ?? 'Posts',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Builder(
          builder: (context) {
            if (_error != null) {
              return _ErrorState(
                message: _error!,
                onRetry: () => _load(reset: true),
              );
            }
            if (_firstLoad) {
              return const _LoadingState();
            }
            if (_items.isEmpty) {
              return const _EmptyState();
            }

            final showBottomSpinner =
                _isLoadingMore || (_loading && _items.isNotEmpty);

            return ListView.builder(
              controller: _scroll,
              padding: EdgeInsets.zero,
              itemCount: _items.length + (showBottomSpinner ? 1 : 0),
              itemBuilder: (context, index) {
                // spinner bawah
                if (index == _items.length) {
                  return Padding(
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
                  );
                }

                if (index < 0 || index >= _items.length) {
                  return const SizedBox.shrink();
                }

                final p = _items[index];

                // header user: kalau null & ini halaman self, fallback session
                final headerUser =
                    p.user ??
                    (widget.userId == me?.id
                        ? BasicUser(
                            id: me!.id,
                            username: me.username ?? me.email.split('@').first,
                            email: me.email,
                            profilePictureUrl: me.profilePictureUrl,
                          )
                        : null);

                final item = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (headerUser != null)
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        leading: CircleAvatar(
                          backgroundImage:
                              (headerUser.profilePictureUrl?.isNotEmpty ??
                                  false)
                              ? NetworkImage(headerUser.profilePictureUrl!)
                              : null,
                          child:
                              (headerUser.profilePictureUrl == null ||
                                  headerUser.profilePictureUrl!.isEmpty)
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          headerUser.username,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(_timeAgo(p.createdAtLocal)),
                        onTap: () => context.go('/profile/${headerUser.id}'),
                      ),

                    // gambar + tap → detail
                    AspectRatio(
                      aspectRatio: 1,
                      child: GestureDetector(
                        onTap: () => context.push('/post/${p.id}'),
                        child: Hero(
                          tag: 'post-${p.id}',
                          child: Image.network(
                            p.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Center(
                              child: Icon(Icons.broken_image_outlined),
                            ),
                            loadingBuilder: (c, child, prog) => (prog == null)
                                ? child
                                : Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    // caption & likes
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((p.totalLikes ?? 0) > 0)
                            Text(
                              '${p.totalLikes} likes',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if ((p.caption ?? '').trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              p.caption!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                );

                // tandai item target untuk auto-jump
                if (_targetIndex != null && index == _targetIndex) {
                  return KeyedSubtree(key: _targetKey, child: item);
                }
                return item;
              },
            );
          },
        ),
      ),
    );
  }
}

// ===================== states (selaras FeedPage) =====================

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade100, Colors.pink.shade100],
              ),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.purple.shade400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Memuat postingan...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Terjadi Kesalahan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade100, Colors.pink.shade100],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_outlined,
                size: 80,
                color: Colors.purple.shade400,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Belum ada post',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Pengguna ini belum memiliki postingan.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
