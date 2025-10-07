import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppSuccess extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onDone;
  final double size;

  const AppSuccess({
    super.key,
    required this.title,
    this.message,
    this.onDone,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/success.json',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            if (onDone != null)
              FilledButton(onPressed: onDone, child: const Text('OK')),
          ],
        ),
      ),
    );
  }
}
