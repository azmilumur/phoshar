// lib/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phoshar/features/posts/presentation/post_detail_page.dart';

import 'features/posts/presentation/user_post_page.dart';
import 'app_router_refresh.dart';
import 'features/auth/controllers/session_controller.dart';

// Auth pages
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/register_page.dart';

// Shell (bottom nav)
import 'features/shell/bottom_nav_shell.dart';

// Feed / Explore / Create
import 'features/posts/presentation/feed_page.dart';
import 'features/posts/presentation/explore_page.dart';
import 'features/posts/presentation/create_post_page.dart';

// Profile
import 'features/profile/presentation/profile_page.dart';

// Social
import 'features/social/presentation/user_list_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionControllerProvider);
  final refresh = ref.watch(routerRefreshListenableProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    routes: [
      // ===== Auth Routes =====
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

      // ===== Main App (BottomNav Shell) =====
      ShellRoute(
        builder: (_, __, child) => BottomNavShell(child: child),
        routes: [
          // 🏠 Home / Feed
          GoRoute(path: '/', builder: (_, __) => const FeedPage()),

          // 🔍 Explore
          GoRoute(path: '/explore', builder: (_, __) => const ExplorePage()),

          // ➕ Create Post
          GoRoute(path: '/create', builder: (_, __) => const CreatePostPage()),

          // 👤 My Profile
          GoRoute(
            path: '/profile',
            builder: (_, __) => Consumer(
              builder: (context, ref, _) {
                final me = ref.watch(sessionControllerProvider).asData?.value;
                if (me == null) {
                  // fallback ke login kalau belum ada user
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go('/login');
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return ProfilePage(userId: me.id);
              },
            ),
          ),

          GoRoute(
            path: '/post/:id', // tanpa slash depan, jadi child dari shell
            builder: (context, state) {
              final postId = state.pathParameters['id']!;
              return PostDetailPage(postId: postId);
            },
          ),

          // 👤 Other Profile
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

          // 📸 My Posts
          GoRoute(
            path: '/my-posts',
            builder: (_, state) => Consumer(
              builder: (context, ref, _) {
                final me = ref.watch(sessionControllerProvider).asData?.value;
                final extra = (state.extra is Map)
                    ? state.extra as Map
                    : const {};
                if (me == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go('/login');
                  });
                  return const SizedBox();
                }
                return UsersPostsPage(
                  userId: me.id,
                  title: 'My Posts',
                  initialIndex: extra['initialIndex'] as int?,
                );
              },
            ),
          ),

          // 📸 Other user's posts
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

          // 👥 Social Lists
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

    // ===== Redirect Logic =====
    redirect: (context, state) {
      final loggedIn = session.asData?.value != null;
      final onLogin = state.matchedLocation == '/login';
      final onRegister = state.matchedLocation == '/register';

      // 1️⃣ Saat app baru di-run, biar gak auto-login
      // kalau hot restart, sessionController.build() belum restore
      if (session.isLoading) return null;

      // 2️⃣ kalau belum login → selalu ke /login (kecuali lagi di login/register)
      if (!loggedIn && !onLogin && !onRegister) return '/login';

      // 3️⃣ kalau udah login tapi masih di /login atau /register → ke home
      if (loggedIn && (onLogin || onRegister)) return '/';

      // 4️⃣ sisanya stay
      return null;
    },
  );
});
