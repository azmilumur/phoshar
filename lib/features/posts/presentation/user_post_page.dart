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
  final int? initialIndex; // index global (0 = terbaru)
  final int? pageSize;

  @override
  ConsumerState<UsersPostsPage> createState() => _UsersPostsPageState();
}

class _UsersPostsPageState extends ConsumerState<UsersPostsPage> {
  static const _defaultSize = 10;

  late final int _size;
  final _scroll = ScrollController();
  final _items = <Photo>[];

  int _page = 1;
  bool _loading = false; // loading halaman berikut
  bool _firstLoad = true; // loading awal
  bool _hasMore = true;
  String? _error;

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
    _scroll.dispose();
    super.dispose();
  }

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

  void _onScroll() {
    if (!_hasMore || _loading) return;
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 480) {
      _load();
    }
  }

  Future<void> _refresh() async {
    await _load(reset: true);
    if (_targetIndex != null) {
      await _loadUntilTarget();
      _tryJumpToTarget();
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

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(sessionControllerProvider).asData?.value;

    Widget body;

    if (_error != null) {
      body = ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Gagal memuat: $_error'),
          ),
        ],
      );
    } else if (_firstLoad) {
      body = ListView(
        children: const [
          SizedBox(height: 160),
          Center(child: CircularProgressIndicator()),
        ],
      );
    } else if (_items.isEmpty) {
      body = ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text('Belum ada post')),
          SizedBox(height: 120),
        ],
      );
    } else {
      body = ListView.builder(
        controller: _scroll,
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final p = _items[index];

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

          final itemContent = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (headerUser != null)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: CircleAvatar(
                    backgroundImage:
                        (headerUser.profilePictureUrl?.isNotEmpty ?? false)
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

              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  p.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      const Center(child: Icon(Icons.broken_image_outlined)),
                ),
              ),

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
                        style: const TextStyle(fontWeight: FontWeight.w600),
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

          if (_targetIndex != null && index == _targetIndex) {
            return KeyedSubtree(key: _targetKey, child: itemContent);
          }
          return itemContent;
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Posts')),
      body: RefreshIndicator(onRefresh: _refresh, child: body),
    );
  }
}
