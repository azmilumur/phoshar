import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppEmptyState extends StatelessWidget {
  final String message;
  final double size;

  const AppEmptyState({
    super.key,
    required this.message,
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
              'assets/animations/empty.json',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
