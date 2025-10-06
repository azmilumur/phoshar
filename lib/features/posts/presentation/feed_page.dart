import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/controllers/session_controller.dart'; // AuthUser? dari login
import '../../posts/data/photo.dart';
import '../../posts/data/post_repository.dart';

enum FeedTab { following, mine }

class FeedTwoTabsPage extends ConsumerStatefulWidget {
  const FeedTwoTabsPage({super.key});
  @override
  ConsumerState<FeedTwoTabsPage> createState() => _FeedTwoTabsPageState();
}

class _FeedTwoTabsPageState extends ConsumerState<FeedTwoTabsPage> {
  static const _pageSize = 12;

  FeedTab _tab = FeedTab.following;
  final _scroll = ScrollController();

  // Following state
  final _following = <Photo>[];
  int _followingPage = 1;
  bool _followingMore = true;
  bool _followingLoading = false;

  // Mine state
  final _mine = <Photo>[];
  int _minePage = 1;
  bool _mineMore = true;
  bool _mineLoading = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(reset: true));
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // Helpers utk state tab aktif
  List<Photo> get _list => _tab == FeedTab.following ? _following : _mine;
  bool get _loading =>
      _tab == FeedTab.following ? _followingLoading : _mineLoading;
  bool get _hasMore => _tab == FeedTab.following ? _followingMore : _mineMore;

  void _switch(FeedTab t) {
    if (_tab == t) return;
    setState(() => _tab = t);
    if (_list.isEmpty) _load(reset: true);
    // opsional: scroll ke atas saat ganti tab
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  Future<void> _load({bool reset = false}) async {
    final repo = ref.read(postsRepositoryProvider);
    final me = ref.read(sessionControllerProvider).asData?.value;

    if (_tab == FeedTab.following) {
      if (_followingLoading) return;
      setState(() => _followingLoading = true);
      try {
        if (reset) _followingPage = 1;
        final items = await repo.getFollowing(
          page: _followingPage,
          size: _pageSize,
        );
        _followingMore = items.length == _pageSize;
        if (_followingPage == 1) {
          _following
            ..clear()
            ..addAll(items);
        } else {
          _following.addAll(items);
        }
        _followingPage++;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal memuat Following: $e')));
        }
      } finally {
        if (mounted) setState(() => _followingLoading = false);
      }
    } else {
      if (_mineLoading) return;
      if (me == null) return;
      setState(() => _mineLoading = true);
      try {
        if (reset) _minePage = 1;
        final items = await repo.getByUser(
          me.id,
          page: _minePage,
          size: _pageSize,
        );
        _mineMore = items.length == _pageSize;
        if (_minePage == 1) {
          _mine
            ..clear()
            ..addAll(items);
        } else {
          _mine.addAll(items);
        }
        _minePage++;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal memuat My Posts: $e')));
        }
      } finally {
        if (mounted) setState(() => _mineLoading = false);
      }
    }
  }

  Future<void> _refresh() => _load(reset: true);

  void _onScroll() {
    if (_loading || !_hasMore) return;
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 480) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(sessionControllerProvider).asData?.value;

    final initLoading = _loading && _list.isEmpty;

    // Aman dari index out of range:
    //  - 1 baris: switcher
    //  - 1 baris: loader/empty (hanya saat list kosong)
    //  - N baris: data
    //  - 1 baris: spinner paginasi (hanya jika _loading && list tidak kosong)
    final topRows = 1 /* switcher */ + ((_list.isEmpty) ? 1 : 0);
    final bottomRows = (_loading && _list.isNotEmpty) ? 1 : 0;
    final itemCount = topRows + _list.length + bottomRows;

    return Scaffold(
      appBar: AppBar(title: const Text('Feed'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          controller: _scroll,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            // ROW 0: switcher
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: SegmentedButton<FeedTab>(
                    segments: const [
                      ButtonSegment(
                        value: FeedTab.following,
                        label: Text('Following'),
                        icon: Icon(Icons.people_alt),
                      ),
                      ButtonSegment(
                        value: FeedTab.mine,
                        label: Text('My Posts'),
                        icon: Icon(Icons.person),
                      ),
                    ],
                    selected: {_tab},
                    onSelectionChanged: (s) => _switch(s.first),
                  ),
                ),
              );
            }

            // ROW 1 (hanya saat list kosong): spinner/empty
            if (topRows > 1 && index == 1) {
              if (initLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: Text('Belum ada post')),
              );
            }

            // Data index = index - topRows
            final dataIndex = index - topRows;

            // Baris data
            if (dataIndex >= 0 && dataIndex < _list.length) {
              final p = _list[dataIndex];

              // user dari API: following-post ada user; users-post (mine) user == null
              final headerUser =
                  p.user ??
                  (me == null
                      ? null
                      : BasicUser(
                          id: me.id,
                          username: me.username ?? me.email.split('@').first,
                          email: me.email,
                          profilePictureUrl: me.profilePictureUrl,
                        ));
              return _PostCard(post: p, headerUser: headerUser);
            }

            // ROW terakhir: spinner saat paginasi (hanya ketika _loading && list tidak kosong)
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.headerUser});
  final Photo post;
  final BasicUser? headerUser;

  // Parse ISO string agar aman (createdAt itu String? dari API)
  String _timeAgoIso(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final t = DateTime.tryParse(iso)?.toLocal();
    if (t == null) return '';
    final d = DateTime.now().difference(t);
    if (d.inDays >= 1) return '${d.inDays}d';
    if (d.inHours >= 1) return '${d.inHours}h';
    if (d.inMinutes >= 1) return '${d.inMinutes}m';
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    final caption = (post.caption ?? '').trim();
    final likes = post.totalLikes ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (headerUser != null)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: CircleAvatar(
              backgroundImage:
                  (headerUser!.profilePictureUrl?.isNotEmpty ?? false)
                  ? NetworkImage(headerUser!.profilePictureUrl!)
                  : null,
              child:
                  (headerUser!.profilePictureUrl == null ||
                      headerUser!.profilePictureUrl!.isEmpty)
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(
              headerUser!.username,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(_timeAgoIso(post.createdAt)),
            onTap: () => context.go('/profile/${headerUser!.id}'),
          ),

        AspectRatio(
          aspectRatio: 1,
          child: Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) =>
                const Center(child: Icon(Icons.broken_image_outlined)),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (likes > 0)
                Text(
                  '$likes likes',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              if (caption.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(caption, maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
