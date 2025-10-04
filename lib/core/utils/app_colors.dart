import 'package:flutter/material.dart';

class AppColors {
  // Light Theme
  static const Color lightPrimary = Color(0xFFFF645C);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFFFF9800);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF000000);
  static const Color lightOnSurface = Color(0xFF000000);
  static const Color lightOutline = Color(0xFFE0E0E0);
  static const Color lightError = Color(0xFFB00020);
  static const Color lightOnError = Color(0xFFFFFFFF);

  // Dark Theme
  static const Color darkPrimary = Color(0xFFFF645C);
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkSecondary = Color(0xFFFF9800);
  static const Color darkOnSecondary = Color(0xFF000000);
  static const Color darkBackground = Color(0xFF212121);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOutline = Color(0xFF424242);
  static const Color darkError = Color(0xFFB00020);
  static const Color darkOnError = Color(0xFF000000);

  // Shared
  static const Color snackbarError = Color(0xFFB00020);
  static const Color snackbarSuccess = Color(0xFFF35350);
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
