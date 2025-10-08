import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import '../controllers/register_controller.dart';

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
  final repeatCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureRepeat = true;

  @override
  void dispose() {
    nameCtrl.dispose();
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    repeatCtrl.dispose();
    super.dispose();
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        Future.delayed(const Duration(seconds: 2), () {
          if (ctx.mounted) {
            Navigator.of(ctx).pop();
            context.go('/login'); // ⬅️ balik ke login
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
  }

  @override
  Widget build(BuildContext context) {
    final regState = ref.watch(registerControllerProvider);

    ref.listen(registerControllerProvider, (prev, next) {
      final wasLoading = prev?.isLoading == true;
      final nowLoaded = next.hasValue && !next.isLoading;

      // hanya tampilkan animasi kalau benar-benar barusan register
      if (wasLoading && nowLoaded && mounted) {
        _showSuccessAnimation();
      }

      next.whenOrNull(
        error: (e, _) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚠️ ${e.toString()}'),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buat Akun',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bergabunglah dengan komunitas kami',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              _input('Nama', Icons.person_outline, nameCtrl),
              const SizedBox(height: 16),
              _input('Username', Icons.alternate_email, usernameCtrl),
              const SizedBox(height: 16),
              _input(
                'Email',
                Icons.email_outlined,
                emailCtrl,
                type: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _input(
                'Password',
                Icons.lock_outline,
                passCtrl,
                obscure: _obscurePassword,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey[600],
                  ),
                  onPressed:
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 16),

              _input(
                'Ulangi Password',
                Icons.lock_outline,
                repeatCtrl,
                obscure: _obscureRepeat,
                suffix: IconButton(
                  icon: Icon(
                    _obscureRepeat
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey[600],
                  ),
                  onPressed:
                      () => setState(() => _obscureRepeat = !_obscureRepeat),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      regState.isLoading
                          ? null
                          : () async {
                            await ref
                                .read(registerControllerProvider.notifier)
                                .register(
                                  name: nameCtrl.text.trim(),
                                  username: usernameCtrl.text.trim(),
                                  email: emailCtrl.text.trim(),
                                  password: passCtrl.text,
                                  passwordRepeat: repeatCtrl.text,
                                );
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade400, Colors.pink.shade400],
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
                    child: Center(
                      child:
                          regState.isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              )
                              : const Text(
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
    String label,
    IconData icon,
    TextEditingController ctrl, {
    bool obscure = false,
    Widget? suffix,
    TextInputType? type,
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
        controller: ctrl,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
