import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Light Theme
  static const Color backgroundLight = Color(0xFFE0E5EC);
  static const Color cardLight = Color(0xFFE0E5EC);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF777777);
  static const Color accent = Color(0xFF1DA1F2); // X Blue
  static const Color warning = Color(0xFFE53935);

  // Dark Theme
  static const Color backgroundDark = Color(0xFF2D2D2D);
  static const Color cardDark = Color(0xFF2D2D2D);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);

  // Neumorphic shadows (Light)
  static Color shadowLightTop = Colors.white.withValues(alpha: 0.8);
  static Color shadowLightBottom = Colors.black.withValues(alpha: 0.15);

  // Neumorphic shadows (Dark)
  static Color shadowDarkTop = Colors.white.withValues(alpha: 0.1);
  static Color shadowDarkBottom = Colors.black.withValues(alpha: 0.4);
}
