import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLoading extends StatelessWidget {
  final String? message;
  final double size;

  const AppLoading({super.key, this.message, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/loading.json',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }
}
