import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Orange theme from original)
  static const Color primary = Color(0xFFFF5722);
  static const Color primaryVariant = Color(0xFFD84315);
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryVariant = Color(0xFFF57C00);
  static const Color onSecondary = Color(0xFFFFFFFF);
  
  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF000000);
  static const Color onSurface = Color(0xFF000000);
  
  // Error Colors
  static const Color error = Color(0xFFB00020);
  static const Color onError = Color(0xFFFFFFFF);
  
  // Additional Colors
  static const Color outline = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1F000000);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurfaceVariant = Color(0xFF666666);
  
  // Material Swatch
  static const MaterialColor primarySwatch = MaterialColor(
    0xFFFF5722,
    <int, Color>{
      50: Color(0xFFFFEBEE),
      100: Color(0xFFFFCDD2),
      200: Color(0xFFEF9A9A),
      300: Color(0xFFE57373),
      400: Color(0xFFEF5350),
      500: Color(0xFFFF5722),
      600: Color(0xFFE53935),
      700: Color(0xFFD32F2F),
      800: Color(0xFFC62828),
      900: Color(0xFFB71C1C),
    },
  );
}
