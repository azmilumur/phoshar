import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final double size;

  const AppError({
    super.key,
    required this.message,
    this.onRetry,
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
              'assets/animations/error.json',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: const Text("Coba Lagi"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
