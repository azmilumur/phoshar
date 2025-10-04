import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import 'package:phoshar/core/widgets/app_text_field.dart';
import 'package:phoshar/core/widgets/app_button.dart';

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

  @override
  void initState() {
    super.initState();

    // ⬇️ Pindahkan ref.listen ke sini biar gak ke-reset tiap build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<AsyncValue>(authControllerProvider, (prev, next) async {
        debugPrint('📦 state berubah → ${next.runtimeType}');
        debugPrint(
            '  hasError: ${next.hasError}, hasValue: ${next.hasValue}, isLoading: ${next.isLoading}');
        debugPrint('  value: ${next.value}');

        if (next.hasError) {
          final errMsg = next.error.toString();
          debugPrint('❌ Listener deteksi error: $errMsg');
          if (mounted) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    errMsg.contains('taken')
                        ? 'Email sudah terdaftar, coba email lain'
                        : errMsg,
                  ),
                  backgroundColor: Colors.red[400],
                ),
              );
          }
          return;
        }

        final wasLoading = prev?.isLoading == true;
        final isNowSuccess =
            next.hasValue && next.value == null && !next.hasError;

        if (wasLoading && isNowSuccess && mounted) {
          debugPrint('✅ Listener deteksi register sukses → tampilkan popup');
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Registrasi Berhasil"),
              content: const Text("Akun berhasil dibuat. Silakan login."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.go('/login');
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/login')),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Daftar',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                AppTextField(controller: nameCtrl, label: 'Name'),
                const SizedBox(height: 12),
                AppTextField(controller: usernameCtrl, label: 'Username'),
                const SizedBox(height: 12),
                AppTextField(
                  controller: emailCtrl,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: passCtrl,
                  label: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: pass2Ctrl,
                  label: 'Konfirmasi Password',
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Buat Akun',
                  isLoading: state.isLoading,
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final username = usernameCtrl.text.trim();
                    final email = emailCtrl.text.trim();
                    final pass = passCtrl.text;
                    final pass2 = pass2Ctrl.text;

                    if (name.isEmpty ||
                        username.isEmpty ||
                        email.isEmpty ||
                        pass.isEmpty ||
                        pass2.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Semua kolom wajib diisi'),
                        ),
                      );
                      return;
                    }
                    if (pass.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password minimal 6 karakter'),
                        ),
                      );
                      return;
                    }
                    if (pass != pass2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Konfirmasi password tidak sama'),
                        ),
                      );
                      return;
                    }

                    await ref.read(authControllerProvider.notifier).register(
                          name: name,
                          username: username,
                          email: email,
                          password: pass,
                          passwordRepeat: pass2,
                        );
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Sudah punya akun? Masuk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
