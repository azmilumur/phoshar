// lib/features/auth/presentation/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/registers_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});
  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final nameCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final pass2Ctrl = TextEditingController();
  final picCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  final webCtrl = TextEditingController();
  bool vis1 = false, vis2 = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    picCtrl.dispose();
    phoneCtrl.dispose();
    bioCtrl.dispose();
    webCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reg = ref.watch(registerControllerProvider);

    ref.listen(registerControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString()))),
        data: (_) {
          // sukses → server tidak kirim token → arahkan manual ke login
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Akun dibuat. Silakan login.')),
          );
          context.go('/login');
        },
      );
    });

    InputDecoration deco(String label) =>
        InputDecoration(labelText: label, border: const OutlineInputBorder());

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                TextField(controller: nameCtrl, decoration: deco('Name')),
                const SizedBox(height: 12),
                TextField(
                  controller: usernameCtrl,
                  decoration: deco('Username'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: deco('Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passCtrl,
                  obscureText: !vis1,
                  decoration: deco('Password').copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => vis1 = !vis1),
                      icon: Icon(
                        vis1 ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pass2Ctrl,
                  obscureText: !vis2,
                  decoration: deco('Password Repeat').copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => vis2 = !vis2),
                      icon: Icon(
                        vis2 ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: picCtrl,
                  decoration: deco('Profile Picture URL (opsional)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: deco('Phone (opsional)'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bioCtrl,
                  decoration: deco('Bio (opsional)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: webCtrl,
                  decoration: deco('Website (opsional)'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: reg.isLoading
                        ? null
                        : () async {
                            if (nameCtrl.text.trim().isEmpty ||
                                usernameCtrl.text.trim().isEmpty ||
                                emailCtrl.text.trim().isEmpty ||
                                passCtrl.text.isEmpty ||
                                pass2Ctrl.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Semua field wajib kecuali yang bertanda opsional',
                                  ),
                                ),
                              );
                              return;
                            }
                            if (passCtrl.text != pass2Ctrl.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Konfirmasi password tidak sama',
                                  ),
                                ),
                              );
                              return;
                            }
                            await ref
                                .read(registerControllerProvider.notifier)
                                .register(
                                  name: nameCtrl.text.trim(),
                                  username: usernameCtrl.text.trim(),
                                  email: emailCtrl.text.trim(),
                                  password: passCtrl.text,
                                  passwordRepeat: pass2Ctrl.text,
                                  profilePictureUrl: picCtrl.text.trim().isEmpty
                                      ? null
                                      : picCtrl.text.trim(),
                                  phoneNumber: phoneCtrl.text.trim().isEmpty
                                      ? null
                                      : phoneCtrl.text.trim(),
                                  bio: bioCtrl.text.trim().isEmpty
                                      ? null
                                      : bioCtrl.text.trim(),
                                  website: webCtrl.text.trim().isEmpty
                                      ? null
                                      : webCtrl.text.trim(),
                                );
                          },
                    child: reg.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Daftar'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Sudah punya akun? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
