// lib/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/posts/presentation/user_post_page.dart';

// Refresh + session
import 'app_router_refresh.dart';
import 'features/auth/controllers/session_controller.dart';

// Auth
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/register_page.dart';

// Shell (bottom nav)
import 'features/shell/bottom_nav_shell.dart';

// Home (Feed: Following & My Posts)
// NOTE: pastikan file & class sesuai project kamu.
// Jika class-nya `FeedTwoTabsPage` ada di feed_page.dart, import ini OK.
import 'features/posts/presentation/feed_page.dart';

// (opsional) Explore & Create
import 'features/posts/presentation/explore_page.dart';
import 'features/posts/presentation/create_post_page.dart';

// Profile
import 'features/profile/presentation/profile_page.dart';

// Users list (Followers/Following)
// ❗️SAMAKAN dengan nama file yang kamu pakai: user_list_page.dart atau users_list_page.dart
import 'features/social/presentation/user_list_page.dart';
// file ini harus mengekspor: UsersListPage & UsersListMode

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionControllerProvider);
  final refresh = ref.watch(routerRefreshListenableProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    routes: [
      // ===== Auth =====
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

      // ===== App (Shell + Bottom Tabs) =====
      ShellRoute(
        builder: (_, __, child) => BottomNavShell(child: child),
        routes: [
          // Home (Feed 2 tab: Following & My Posts)
          GoRoute(path: '/', builder: (_, __) => const FeedTwoTabsPage()),

          // (opsional) Explore & Create
          GoRoute(path: '/explore', builder: (_, __) => const ExplorePage()),
          GoRoute(path: '/create', builder: (_, __) => const CreatePostPage()),

          // Profile (self)
          GoRoute(
            path: '/profile',
            builder: (_, __) => Consumer(
              builder: (context, ref, _) {
                final me = ref.watch(sessionControllerProvider).asData?.value;
                return ProfilePage(userId: me!.id);
              },
            ),
          ),

          // Profile (others) — dukung initialIsFollowing via extra
          GoRoute(
            path: '/profile/:id',
            builder: (_, s) {
              final extra = (s.extra is Map) ? s.extra as Map : const {};
              return ProfilePage(
                userId: s.pathParameters['id']!,
                initialIsFollowing: extra['isFollowing'] == true,
                initialName: extra['name'] as String?,
                initialUsername: extra['username'] as String?,
                initialAvatarUrl: extra['avatar'] as String?,
                initialEmail: extra['email'] as String?,
              );
            },
          ),

          // My Posts (self)
          GoRoute(
            path: '/my-posts',
            builder: (_, state) => Consumer(
              builder: (context, ref, _) {
                final me = ref.watch(sessionControllerProvider).asData?.value;
                final extra = (state.extra is Map)
                    ? state.extra as Map
                    : const {};
                return UsersPostsPage(
                  userId: me!.id,
                  title: 'My Posts',
                  initialIndex: extra['initialIndex'] as int?,
                );
              },
            ),
          ),

          // Posts milik user lain
          GoRoute(
            path: '/users/:id/posts',
            builder: (_, state) {
              final extra = (state.extra is Map)
                  ? state.extra as Map
                  : const {};
              return UsersPostsPage(
                userId: state.pathParameters['id']!,
                title: 'Posts',
                initialIndex: extra['initialIndex'] as int?,
              );
            },
          ),

          // ===== Users list routes =====
          GoRoute(
            path: '/users/my-following',
            builder: (_, __) => const UsersListPage(
              mode: UsersListMode.myFollowing,
              title: 'My Following',
            ),
          ),
          GoRoute(
            path: '/users/my-followers',
            builder: (_, __) => const UsersListPage(
              mode: UsersListMode.myFollowers,
              title: 'My Followers',
            ),
          ),
          GoRoute(
            path: '/users/:id/following',
            builder: (_, s) => UsersListPage(
              mode: UsersListMode.followingOf,
              userId: s.pathParameters['id']!,
              title: 'Following',
            ),
          ),
          GoRoute(
            path: '/users/:id/followers',
            builder: (_, s) => UsersListPage(
              mode: UsersListMode.followersOf,
              userId: s.pathParameters['id']!,
              title: 'Followers',
            ),
          ),
        ],
      ),
    ],

    // ===== Auth guard / redirect =====
    redirect: (context, state) {
      final loggedIn = session.asData?.value != null;
      final onAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (!loggedIn && !onAuth) return '/login';
      if (loggedIn && onAuth) return '/';
      return null;
    },
  );
});
