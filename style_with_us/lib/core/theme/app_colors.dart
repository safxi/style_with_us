import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary Color - Main brand accent, high glow.
  static const Color primary = Color(0xFF06B6D4);

  // Background and Surface Colors - Base card background.
  static const Color background = Color(0xFF0F172A); // using surface color for background
  static const Color surface = Color(0xFF0F172A);
  
  // Elevated layer background
  static const Color surfaceContainer = Color(0xFF1E293B);

  // Secondary interactive accent
  static const Color accentGlow = Color(0xFF818CF8);
  
  // Destructive actions and alerts
  static const Color error = Color(0xFFF43F5E);
  
  // Kept for backward compatibility
  static const Color accent = Color(0xFF818CF8); // Mapped to Accent-Glow
  static const Color textMuted = Color(0xFF8E8EA9);
}
