import 'package:flutter/material.dart';

class AppColors {
  // Light Theme
  static const Color lightPrimary = Color(0xFFFF645C);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFFFF9800);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF1A1A2E);
  static const Color lightOnSurface = Color(0xFF1A1A2E);
  static const Color lightOutline = Color(0xFFE0E0E0);
  static const Color lightError = Color(0xFFB00020);
  static const Color lightOnError = Color(0xFFFFFFFF);
  
  // Light Theme - Text Colors
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextDisabled = Color(0xFF9CA3AF);

  // Dark Theme - Modern Navy/Purple
  static const Color darkPrimary = Color(0xFFFF645C);
  static const Color darkOnPrimary = Color(0xFFFFFFFF);
  static const Color darkSecondary = Color(0xFFFF9800);
  static const Color darkOnSecondary = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF16213E); // Modern dark blue
  static const Color darkSurface = Color(0xFF1E2746); // Card background
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOutline = Color(0xFF2E3A59); // Border color
  static const Color darkError = Color(0xFFEF4444);
  static const Color darkOnError = Color(0xFFFFFFFF);
  
  // Dark Theme - Text Colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextDisabled = Color(0xFF6B7280);

  // Modern Header Colors
  static const Color darkHeaderStart = Color(0xFF1A1A2E); // Gradient start
  static const Color darkHeaderEnd = Color(0xFF16213E); // Gradient end
  static const Color darkCardBackground = Color(0xFF1E2746); // Cards
  static const Color darkCardBorder = Color(0xFF2E3A59); // Borders
  
  static const Color lightHeaderStart = Color(0xFFFAFAFA); // Gradient start
  static const Color lightHeaderEnd = Color(0xFFFFFFFF); // Gradient end
  static const Color lightCardBackground = Color(0xFFFFFFFF); // Cards
  static const Color lightCardBorder = Color(0xFFEEEEEE); // Borders

  // Status Colors (Universal)
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Snackbar Colors (Theme-Aware)
  // Light Theme Snackbars - Darker for contrast on light background
  static const Color lightSnackbarError = Color(0xFFDC2626);      // Darker red
  static const Color lightSnackbarSuccess = Color(0xFF059669);    // Darker green
  static const Color lightSnackbarWarning = Color(0xFFD97706);    // Darker amber
  static const Color lightSnackbarInfo = Color(0xFF2563EB);       // Darker blue
  
  // Dark Theme Snackbars - Lighter/Vibrant for contrast on dark background
  static const Color darkSnackbarError = Color(0xFFF87171);       // Lighter red
  static const Color darkSnackbarSuccess = Color(0xFF34D399);     // Lighter green
  static const Color darkSnackbarWarning = Color(0xFFFBBF24);     // Lighter amber
  static const Color darkSnackbarInfo = Color(0xFF60A5FA);        // Lighter blue
  
  // Legacy support (defaults to dark theme colors)
  static const Color snackbarError = darkSnackbarError;
  static const Color snackbarSuccess = darkSnackbarSuccess;
  static const Color snackbarWarning = darkSnackbarWarning;
  static const Color snackbarInfo = darkSnackbarInfo;
}
