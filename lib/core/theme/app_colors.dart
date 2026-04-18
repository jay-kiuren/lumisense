import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF09090B); // Extremely dark gray/black
  static const Color surface = Color(0xFF18181B);    // Slightly lighter for panels
  static const Color surfaceHighlight = Color(0xFF27272A); // Hover/border color

  // Text
  static const Color textPrimary = Color(0xFFFAFAFA); // Off-white
  static const Color textSecondary = Color(0xFFA1A1AA); // Muted gray
  static const Color textTertiary = Color(0xFF71717A); // Darker gray

  // Accents & States
  static const Color primary = Color(0xFF3B82F6); // Blue accent
  static const Color primaryMuted = Color(0xFF1D4ED8); // Darker blue

  static const Color success = Color(0xFF10B981); // Emerald green (Quiet)
  static const Color warning = Color(0xFFF59E0B); // Amber (Moderate noise)
  static const Color error = Color(0xFFEF4444);   // Red (Alert/Loud)
  static const Color offline = Color(0xFF52525B); // Gray out

  // Chart Gradients
  static const List<Color> chartGradientAm = [
    Color(0xFF3B82F6),
    Color(0x003B82F6),
  ];
  static const List<Color> chartGradientPm = [
    Color(0xFF10B981),
    Color(0x0010B981),
  ];
}
