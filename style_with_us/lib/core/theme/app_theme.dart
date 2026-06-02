import 'package:flutter/material.dart';
import 'style_tokens.dart';

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryPurple,
    colorScheme: base.colorScheme.copyWith(
      primary: primaryPurple,
      secondary: primaryPink,
      surface: surfaceColor,
      error: errorRed,
      background: backgroundColor,
    ),
    textTheme: const TextTheme(
      displayLarge: h1,
      displayMedium: h2,
      displaySmall: h3,
      headlineMedium: h4,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: buttonText,
      labelSmall: caption,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: textPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: Color(0xFFE0E0F0), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: Color(0xFFE0E0F0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryPurple, width: 1.8),
      ),
      hintStyle: bodyMedium.copyWith(color: textMuted),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      shadowColor: Colors.black12,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: primaryPurple,
      unselectedItemColor: textMuted,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
    useMaterial3: true,
  );
}

