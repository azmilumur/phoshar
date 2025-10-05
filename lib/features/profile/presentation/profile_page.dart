// lib/features/profile/presentation/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoshar/core/widgets/app_loading.dart';
import 'package:phoshar/core/widgets/app_error.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Kamu belum login'));
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: (user.profilePictureUrl ?? '').isNotEmpty
                      ? NetworkImage(user.profilePictureUrl!)
                      : null,
                  child: (user.profilePictureUrl ?? '').isEmpty
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.name ?? user.username ?? 'User',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(user.email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar'),
                ),
              ],
            ),
          );
        },
        loading: () => const AppLoading(),
        error: (err, _) => AppError(message: err.toString()),
      ),
    );
  }
}
