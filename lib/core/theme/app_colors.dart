import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF000000); // True Black (Cursor/Apple)
  static const Color surface = Color(0xFF141415);    // Very subtle surface
  static const Color surfaceHighlight = Color(0xFF262628); // Subtle borders (if used)

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure white
  static const Color textSecondary = Color(0xFF8E8E93); // Apple System Gray
  static const Color textTertiary = Color(0xFF636366); // Darker Apple Gray

  // Accents & States
  static const Color primary = Color(0xFF0A84FF); // Apple System Blue
  static const Color primaryMuted = Color(0xFF0040DD); // Darker blue

  static const Color success = Color(0xFF32D74B); // Apple Green
  static const Color warning = Color(0xFFFF9F0A); // Apple Orange
  static const Color error = Color(0xFFFF453A);   // Apple Red
  static const Color offline = Color(0xFF3A3A3C); // Dark Gray

  // Chart Gradients
  static const List<Color> chartGradientAm = [
    Color(0xFF0A84FF),
    Color(0x000A84FF),
  ];
  static const List<Color> chartGradientPm = [
    Color(0xFF32D74B),
    Color(0x0032D74B),
  ];
}
