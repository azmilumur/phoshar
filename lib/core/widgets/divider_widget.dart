// lib/widgets/or_divider.dart
import 'package:flutter/material.dart';
import 'package:phoshar/core/constants/app_colors.dart';

class HorizontalDivider extends StatelessWidget {
  final String text;
  final double height;
  final Color? color;

  const HorizontalDivider({
    super.key,
    this.text = 'or',
    this.height = 1,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = AppColors.divider; // uses theme!
    final dividerColor = color ?? themeColor;

    return Row(
      children: [
        Expanded(
          child: Divider(
            height: height,
            thickness: height,
            color: dividerColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
        ),
        Expanded(
          child: Divider(
            height: height,
            thickness: height,
            color: dividerColor,
          ),
        ),
      ],
    );
  }
}
