// lib/features/profile/presentation/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
            },
          )
        ],
      ),
      body: auth.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (user) {
          if (user == null) {
            return const Center(child: Text("Tidak ada user login"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 48,
                  backgroundImage: (user.profilePictureUrl != null &&
                          user.profilePictureUrl!.isNotEmpty)
                      ? NetworkImage(user.profilePictureUrl!)
                      : null,
                  child: (user.profilePictureUrl == null ||
                          user.profilePictureUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 48)
                      : null,
                ),
                const SizedBox(height: 16),

                // Nama besar
                Text(
                  user.name ?? user.username ?? "User",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "@${user.username ?? '-'}",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),

                // Info user dalam card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _infoRow("Email", user.email),
                        _infoRow("Role", user.role ?? "-"),
                        _infoRow("Phone", user.phoneNumber ?? "-"),
                        _infoRow("Website", user.website ?? "-"),
                        _infoRow("Bio", user.bio ?? "-"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
