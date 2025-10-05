// lib/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phoshar/core/layout/app_shell.dart';
import 'package:phoshar/features/post/presentation/explore_page.dart';
import 'package:phoshar/features/post/presentation/feed_page.dart';
import 'package:phoshar/features/post/presentation/post_detail_page.dart';
import 'package:phoshar/features/profile/presentation/profile_page.dart';

import 'app_router_refresh.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/login/presentation/login_page.dart';
import 'features/auth/register/presentation/register_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  final refreshListenable = ref.watch(routerRefreshListenableProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshListenable,
    routes: [
      GoRoute(
        path: '/',
        builder:
            (context, state) =>
                const AppShell(currentIndex: 0, body: FeedPage()),
        routes: [
          GoRoute(
            path: 'post/:id', // tanpa slash depan, jadi child dari shell
            builder: (context, state) {
              final postId = state.pathParameters['id']!;
              return PostDetailPage(postId: postId);
            },
          ),
        ],
      ),

      GoRoute(
        path: '/feed',
        builder:
            (context, state) =>
                const AppShell(currentIndex: 0, body: FeedPage()),
      ),
      GoRoute(
        path: '/explore',
        builder:
            (context, state) =>
                const AppShell(currentIndex: 1, body: ExplorePage()),
      ),
      GoRoute(
        path: '/profile',
        builder:
            (context, state) =>
                const AppShell(currentIndex: 2, body: ProfilePage()),
      ),

      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(path: '/', builder: (context, state) => const _PlaceholderHome()),
    ],
    redirect: (context, state) {
      final isLoggedIn = auth.asData?.value != null;
      final onLogin = state.matchedLocation == '/login';
      final onRegister = state.matchedLocation == '/register';
      final onProfile = state.matchedLocation == '/profile';

      // 🚫 1. Jangan redirect apa pun saat di /register
      // biar pas email sudah ada, halaman tetap di situ
      if (onRegister) return null;

      // 🚫 2. Kalau masih loading (auth belum siap), jangan redirect
      if (auth.isLoading) return null;

      // ✅ 3. Kalau belum login dan bukan di login/register → ke login
      if (!isLoggedIn && !onLogin && !onRegister) {
        return '/login';
      }

      // ✅ 4. Kalau sudah login tapi masih di login/register → ke profile
      if (isLoggedIn && (onLogin || onRegister)) {
        return '/feed';
      }

      // ✅ 5. Selain itu, stay di halaman sekarang
      return null;
    },
  );
});

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home (placeholder)')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Berhasil login! Nanti ganti jadi Feed Foto.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.go('/login'),
              child: const Text('Ke Login'),
            ),
          ],
        ),
      ),
    );
  }
}
