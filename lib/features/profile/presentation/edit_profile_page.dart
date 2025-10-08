import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:phoshar/features/auth/controllers/session_controller.dart';
import 'package:phoshar/features/profile/data/edit_profile_repository.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(sessionControllerProvider).asData?.value;
      if (user != null) {
        _nameCtrl.text = user.name ?? '';
        _usernameCtrl.text = user.username ?? '';
        _emailCtrl.text = user.email;
        _bioCtrl.text = user.bio ?? '';
        _websiteCtrl.text = user.website ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _bioCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final name = _nameCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty || username.isEmpty || email.isEmpty) {
      _showSnackbar('Nama, username, dan email wajib diisi', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(editProfileRepositoryProvider);
      await repo.updateProfile(
        name: name,
        username: username,
        email: email,
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        website:
            _websiteCtrl.text.trim().isEmpty ? null : _websiteCtrl.text.trim(),
      );

      // Refresh session
      // await ref.read(sessionControllerProvider.notifier).refreshSession();

      if (!mounted) return;
      _showSnackbar('Profil berhasil diperbarui!');
      
      // Show success animation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          Future.delayed(const Duration(seconds: 2), () {
            if (ctx.mounted) {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Go back to profile
            }
          });
          return Center(
            child: Lottie.asset(
              'assets/animations/success.json',
              width: 180,
              height: 180,
              repeat: false,
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackbar('Gagal memperbarui profil: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade300,
                          Colors.pink.shade300,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 49,
                        backgroundImage: ref
                                    .watch(sessionControllerProvider)
                                    .asData
                                    ?.value
                                    ?.profilePictureUrl !=
                                null
                            ? NetworkImage(
                                ref
                                    .watch(sessionControllerProvider)
                                    .asData!
                                    .value!
                                    .profilePictureUrl!,
                              )
                            : null,
                        child: ref
                                    .watch(sessionControllerProvider)
                                    .asData
                                    ?.value
                                    ?.profilePictureUrl ==
                                null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade400,
                            Colors.pink.shade400,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Implement image picker
                  _showSnackbar('Fitur upload foto akan datang!');
                },
                child: Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    color: Colors.purple.shade400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Form Fields
            _buildTextField(
              controller: _nameCtrl,
              label: 'Nama Lengkap',
              icon: Icons.person_outline,
              hint: 'Masukkan nama lengkap',
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _usernameCtrl,
              label: 'Username',
              icon: Icons.alternate_email,
              hint: 'Pilih username unik',
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _emailCtrl,
              label: 'Email',
              icon: Icons.email_outlined,
              hint: 'email@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _bioCtrl,
              label: 'Bio',
              icon: Icons.info_outline,
              hint: 'Ceritakan tentang dirimu',
              maxLines: 3,
              maxLength: 150,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _websiteCtrl,
              label: 'Website',
              icon: Icons.link_outlined,
              hint: 'https://example.com',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade400,
                      Colors.pink.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          counterText: maxLength != null ? null : '',
        ),
      ),
    );
  }
}