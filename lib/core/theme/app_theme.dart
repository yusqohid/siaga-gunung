import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFFD32F2F);      // Red 700
  static const Color primaryContainer = Color(0xFFFFEBEE);
  static const Color secondary = Color(0xFF1E293B);    // Slate 800
  static const Color background = Color(0xFFF8FAFC);   // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100
  
  // Text
  static const Color textPrimary = Color(0xFF0F172A);  // Slate 900
  static const Color textSecondary = Color(0xFF64748B);// Slate 500
  static const Color textMuted = Color(0xFF94A3B8);    // Slate 400
  
  // Activity levels
  static const Color levelIV = Color(0xFFDC2626);      // Red 600 - Awas
  static const Color levelIVBg = Color(0xFFFEF2F2);
  static const Color levelIII = Color(0xFFEA580C);     // Orange 600 - Siaga
  static const Color levelIIIBg = Color(0xFFFFF7ED);
  static const Color levelII = Color(0xFFD97706);      // Amber 600 - Waspada
  static const Color levelIIBg = Color(0xFFFFFBEB);
  static const Color levelI = Color(0xFF16A34A);       // Green 600 - Normal
  static const Color levelIBg = Color(0xFFF0FDF4);
  
  // Status badges
  static const Color freshBadge = Color(0xFF16A34A);
  static const Color staleBadge = Color(0xFFD97706);
  static const Color errorBadge = Color(0xFFDC2626);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        background: AppColors.background,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primaryContainer,
        elevation: 4,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          );
        }),
      ),
    );
  }
}
