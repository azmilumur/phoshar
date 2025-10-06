import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/controllers/session_controller.dart';
import '../data/social_repository.dart';

enum UsersListMode { myFollowing, myFollowers, followingOf, followersOf }

class UsersListPage extends ConsumerStatefulWidget {
  const UsersListPage({super.key, required this.mode, this.userId, this.title});

  final UsersListMode mode;
  final String? userId; // wajib kalau mode followingOf / followersOf
  final String? title;

  @override
  ConsumerState<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends ConsumerState<UsersListPage> {
  final _items = <MiniUser>[];
  final _scroll = ScrollController();

  int _page = 1;
  static const _size = 18;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

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

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _page = 1;
        _hasMore = true;
      }
    });

    try {
      final repo = ref.read(socialRepositoryProvider);
      PagedUsers page;

      switch (widget.mode) {
        case UsersListMode.myFollowing:
          page = await repo.myFollowing(page: _page, size: _size);
          break;
        case UsersListMode.myFollowers:
          page = await repo.myFollowers(page: _page, size: _size);
          break;
        case UsersListMode.followingOf:
          page = await repo.followingOf(
            widget.userId!,
            page: _page,
            size: _size,
          );
          break;
        case UsersListMode.followersOf:
          page = await repo.followersOf(
            widget.userId!,
            page: _page,
            size: _size,
          );
          break;
      }

      if (!mounted) return;
      setState(() {
        if (_page == 1) {
          _items
            ..clear()
            ..addAll(page.users);
        } else {
          _items.addAll(page.users);
        }
        _hasMore = _page < page.totalPages;
        _page++;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _onScroll() {
    if (!_hasMore || _loading) return;
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 320) {
      _load();
    }
  }

  Future<void> _refresh() => _load(reset: true);

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(sessionControllerProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? _titleFromMode())),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _error != null
            ? ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Gagal memuat: $_error'),
                  ),
                ],
              )
            : ListView.separated(
                controller: _scroll,
                itemCount: _items.length + (_hasMore ? 1 : 0),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  // Loader row di paling bawah
                  if (index >= _items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final u = _items[index];
                  final isMe = (me?.id == u.id);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          (u.profilePictureUrl != null &&
                              u.profilePictureUrl!.isNotEmpty)
                          ? NetworkImage(u.profilePictureUrl!)
                          : null,
                      child:
                          (u.profilePictureUrl == null ||
                              u.profilePictureUrl!.isEmpty)
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(u.username ?? u.email ?? 'User'),
                    subtitle: (u.email != null && u.email!.isNotEmpty)
                        ? Text(u.email!)
                        : null,
                    trailing: isMe
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () {
                              // buka profil user ini
                              context.go(
                                '/profile/${u.id}',
                                extra: {
                                  'isFollowing': _presetFollowingFromMode(),
                                  'name': u.username ?? u.email,
                                  'username': u.username,
                                  'avatar': u.profilePictureUrl,
                                  'email': u.email,
                                },
                              );
                            },
                          ),
                    onTap: () {
                      context.go(
                        '/profile/${u.id}',
                        extra: {
                          'isFollowing': _presetFollowingFromMode(),
                          'name': u.username ?? u.email,
                          'username': u.username,
                          'avatar': u.profilePictureUrl,
                          'email': u.email,
                        },
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  String _titleFromMode() {
    switch (widget.mode) {
      case UsersListMode.myFollowing:
        return 'My Following';
      case UsersListMode.myFollowers:
        return 'My Followers';
      case UsersListMode.followingOf:
        return 'Following';
      case UsersListMode.followersOf:
        return 'Followers';
    }
  }

  bool _presetFollowingFromMode() {
    // Kalau datang dari list Following, kita tahu pasti sudah follow.
    return widget.mode == UsersListMode.myFollowing ||
        widget.mode == UsersListMode.followingOf;
  }
}
