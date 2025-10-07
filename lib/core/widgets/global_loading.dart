import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GlobalLoadingWidget extends StatelessWidget {
  const GlobalLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/animations/loading.json',
        width: 200,
        height: 200,
        fit: BoxFit.contain,
      ),
    );
  }
}
