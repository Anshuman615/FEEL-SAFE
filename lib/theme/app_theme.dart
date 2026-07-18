import 'package:flutter/material.dart';

/// Central color palette — matches the "Feel Feel Safe" light theme spec.
class AppColors {
  static const background = Color(0xFFF9F9F9);
  static const sosRed = Color(0xFFFF3B30);
  static const warmOrange = Color(0xFFFFA726);
  static const iosBlue = Color(0xFF007AFF);
  static const almostBlack = Color(0xFF212121);
  static const white = Color(0xFFFFFFFF);
  static const softShadow = Color(0xFFB0BEC5);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.sosRed,
        primary: AppColors.sosRed,
        secondary: AppColors.warmOrange,
        surface: AppColors.white,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.almostBlack,
        ),
        bodyMedium: TextStyle(color: AppColors.almostBlack),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.almostBlack,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.iosBlue,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 2,
        shadowColor: AppColors.softShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
