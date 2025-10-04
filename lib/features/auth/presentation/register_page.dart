// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../../auth/controllers/auth_controller.dart';
// import '../../../core/widgets/app_text_field.dart';
// import '../../../core/widgets/app_button.dart';

// class RegisterPage extends ConsumerStatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   ConsumerState<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends ConsumerState<RegisterPage> {
//   final emailCtrl = TextEditingController();
//   final passCtrl = TextEditingController();
//   final pass2Ctrl = TextEditingController();

//   @override
//   void dispose() {
//     emailCtrl.dispose();
//     passCtrl.dispose();
//     pass2Ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(authControllerProvider);

//     ref.listen(authControllerProvider, (prev, next) {
//       next.whenOrNull(
//         error: (e, _) => ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(e.toString()))),
//         data: (_) {},
//       );
//     });

//     return Scaffold(
//       appBar: AppBar(
//         leading: BackButton(onPressed: () => context.go('/login')),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 420),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const Text(
//                   'Daftar',
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 16),
//                 AppTextField(
//                   controller: emailCtrl,
//                   label: 'Email',
//                   keyboardType: TextInputType.emailAddress,
//                   textInputAction: TextInputAction.next,
//                 ),
//                 const SizedBox(height: 12),
//                 AppTextField(
//                   controller: passCtrl,
//                   label: 'Password',
//                   obscureText: true,
//                   textInputAction: TextInputAction.next,
//                 ),
//                 const SizedBox(height: 12),
//                 AppTextField(
//                   controller: pass2Ctrl,
//                   label: 'Konfirmasi Password',
//                   obscureText: true,
//                   textInputAction: TextInputAction.done,
//                 ),
//                 const SizedBox(height: 16),
//                 AppButton(
//                   label: 'Buat Akun',
//                   isLoading: state.isLoading,
//                   onPressed: () async {
//                     final email = emailCtrl.text.trim();
//                     final pass = passCtrl.text;
//                     final pass2 = pass2Ctrl.text;

//                     if (email.isEmpty || pass.isEmpty || pass2.isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Semua kolom wajib diisi'),
//                         ),
//                       );
//                       return;
//                     }
//                     if (pass.length < 6) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Password minimal 6 karakter'),
//                         ),
//                       );
//                       return;
//                     }
//                     if (pass != pass2) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Konfirmasi password tidak sama'),
//                         ),
//                       );
//                       return;
//                     }

//                     await ref
//                         .read(authControllerProvider.notifier)
//                         .register(email, pass);
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 TextButton(
//                   onPressed: () => context.go('/login'),
//                   child: const Text('Sudah punya akun? Masuk'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
