// lib/features/shell/bottom_nav_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavShell extends StatelessWidget {
  const BottomNavShell({super.key, required this.child});
  final Widget child;

  int _indexFromLocation(String loc) {
    if (loc.startsWith('/explore')) return 1;
    if (loc.startsWith('/create')) return 2;
    if (loc.startsWith('/profile')) return 3;
    return 0; // '/'
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _indexFromLocation(loc);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: idx,
          backgroundColor: Colors.white,
          elevation: 0,
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorColor: Colors.purple.shade50,
          onDestinationSelected: (i) {
            switch (i) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/explore');
                break;
              case 2:
                context.go('/create');
                break;
              case 3:
                context.go('/profile');
                break;
            }
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.grey[600]),
              selectedIcon: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.purple.shade400, Colors.pink.shade400],
                ).createShader(bounds),
                child: const Icon(Icons.home, color: Colors.white),
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined, color: Colors.grey[600]),
              selectedIcon: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.purple.shade400, Colors.pink.shade400],
                ).createShader(bounds),
                child: const Icon(Icons.explore, color: Colors.white),
              ),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.pink.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
              selectedIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.pink.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
              label: 'Create',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: Colors.grey[600]),
              selectedIcon: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.purple.shade400, Colors.pink.shade400],
                ).createShader(bounds),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

