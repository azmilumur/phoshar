// lib/app_router.dart (potongan penting)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_router_refresh.dart';
import 'features/auth/controllers/session_controller.dart';
import 'features/shell/bottom_nav_shell.dart';
import 'features/home/presentation/home_page.dart';
import 'features/posts/presentation/explore_page.dart';
import 'features/posts/presentation/create_post_page.dart';
import 'features/profile/presentation/profile_page.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/register_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionControllerProvider);
  final refresh = ref.watch(routerRefreshListenableProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    routes: [
      // auth routes
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

      // shell with bottom tabs
      ShellRoute(
        builder: (_, __, child) => BottomNavShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomePage()),
          GoRoute(path: '/explore', builder: (_, __) => const ExplorePage()),
          GoRoute(path: '/create', builder: (_, __) => const CreatePostPage()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
        ],
      ),
    ],
    redirect: (context, state) {
      final loggedIn = session.asData?.value != null;
      final onAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (!loggedIn && !onAuth) return '/login';
      if (loggedIn && onAuth) return '/'; // selesai login → ke Home tab
      return null;
    },
  );
});
