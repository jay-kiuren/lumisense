import 'package:flutter/material.dart';

class AppColors {
  // Base layers
  static const Color appBackground = Color(0xFF0A0A0B);
  static const Color sidebar = Color(0xFF000000);
  static const Color workspaceBg = Color(0xFF111113);
  static const Color surface = Color(0xFF1C1C1E);
  static const Color surfaceElevated = Color(0xFF242426);
  static const Color surfaceMuted = Color(0xFF161618);

  // Borders and separators
  static const Color separator = Color(0xFF2C2C2E);
  static const Color borderSubtle = Color(0xFF1F1F21);

  // Text
  static const Color textPrimary = Color(0xFFF2F2F7);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFF48484A);

  // Semantic colors
  static const Color statusLive = Color(0xFF30D158);
  static const Color statusStable = Color(0xFF636366);
  static const Color statusCritical = Color(0xFFFF453A);
  static const Color statusWarning = Color(0xFFFF9F0A);
  static const Color accent = Color(0xFF0A84FF);

  // Legacy aliases for existing widgets
  static const Color background = appBackground;
  static const Color workspace = workspaceBg;
  static const Color surfaceHighlight = surfaceElevated;
  static const Color primary = accent;
  static const Color primaryMuted = textSecondary;
  static const Color success = statusLive;
  static const Color warning = statusWarning;
  static const Color error = statusCritical;
  static const Color offline = statusStable;
  static const Color shadowHeavy = Colors.black;

  static List<BoxShadow> shadowLow = const [
    BoxShadow(color: Color(0xFF000000), blurRadius: 8, offset: Offset(0, 2), spreadRadius: 0),
  ];
  static List<BoxShadow> shadowMedium = const [
    BoxShadow(color: Color(0xFF000000), blurRadius: 20, offset: Offset(0, 4), spreadRadius: -2),
  ];
  static List<BoxShadow> shadowHigh = const [
    BoxShadow(color: Color(0xFF000000), blurRadius: 40, offset: Offset(0, 8), spreadRadius: -4),
  ];

  // Chart Gradients
  static const List<Color> chartGradientAm = [
    Color(0xFFF2F2F7),
    Color(0x00F2F2F7),
  ];
  static const List<Color> chartGradientPm = [
    Color(0xFF30D158),
    Color(0x0030D158),
  ];
}
