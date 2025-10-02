// lib/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_router_refresh.dart'; // <- refreshListenableProvider
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/register_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Auth saat ini (AsyncValue<AuthUser?>)
  final auth = ref.watch(authControllerProvider);
  // Listenable yang akan memaksa router refresh ketika auth berubah
  final refreshListenable = ref.watch(routerRefreshListenableProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshListenable, // <- v16 masih support Listenable
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(path: '/', builder: (context, state) => const _PlaceholderHome()),
    ],
    redirect: (context, state) {
      // Cek login memakai AsyncValue yang ada sekarang
      final isLoggedIn = auth.asData?.value != null;

      // v16: GoRouterState masih punya matchedLocation
      final onAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !onAuthRoute) return '/login';
      if (isLoggedIn && onAuthRoute) return '/';
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
