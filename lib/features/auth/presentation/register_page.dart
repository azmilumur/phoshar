// lib/features/auth/presentation/register_page.dart
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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

  final picCtrl = TextEditingController(); // opsi: tempel URL manual
  final phoneCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  final webCtrl = TextEditingController();

  XFile? picked; // <-- file hasil pilih gambar
  bool vis1 = false, vis2 = false;

  @override
  void initState() {
    super.initState();
    // pastikan state provider fresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(registerControllerProvider);
    });
  }

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final f = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (f != null) setState(() => picked = f);
  }

  @override
  Widget build(BuildContext context) {
    final reg = ref.watch(registerControllerProvider);

    ref.listen(registerControllerProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
      if (prev?.isLoading == true && next.hasValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun dibuat. Silakan login.')),
        );
        context.go('/login');
      }
    });

    InputDecoration deco(String label) =>
        InputDecoration(labelText: label, border: const OutlineInputBorder());

    ImageProvider? _previewImage() {
      if (picked != null) {
        return kIsWeb
            ? NetworkImage(picked!.path) // web menampilkan blob url
            : FileImage(File(picked!.path));
      }
      if (picCtrl.text.trim().isNotEmpty) {
        return NetworkImage(picCtrl.text.trim());
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar + tombol pilih gambar
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: _previewImage(),
                      child: _previewImage() == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Pilih Foto Profil'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

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

                // Opsi: user tempel URL langsung (kalau tidak mau upload)
                TextField(
                  controller: picCtrl,
                  decoration: deco('Profile Picture URL (opsional)'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: phoneCtrl,
                  decoration: deco('Phone (opsional)'),
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
                                  // prioritas upload; kalau tidak ada, pakai URL manual
                                  imageFile: picked,
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
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
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
