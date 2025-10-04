// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:phoshar/core/constants/app_colors.dart';
import 'package:phoshar/core/constants/app_text_styles.dart';

final lightTheme = ThemeData(
  // Use your constants to build the theme
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: AppTextStyles.titleLarge,
    titleMedium: AppTextStyles.titleMedium,
    labelLarge: AppTextStyles.labelLarge,
    labelMedium: AppTextStyles.labelMedium,
    bodySmall: AppTextStyles.bodySmall,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1976D2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
  ),
);
