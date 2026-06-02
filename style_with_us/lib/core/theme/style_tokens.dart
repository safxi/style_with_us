import 'package:flutter/material.dart';

// Colors
const Color primaryPurple = Color(0xFF6B4CE6);
const Color primaryPink = Color(0xFFE94B9C);
const Color primaryBlue = Color(0xFF4C9AE6);

const LinearGradient primaryGradient = LinearGradient(
  colors: [Color(0xFF6B4CE6), Color(0xFFE94B9C)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient softGradient = LinearGradient(
  colors: [Color(0xFFF8F9FF), Color(0xFFFFF5FA)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

final LinearGradient cardGradient = LinearGradient(
  colors: [
    const Color(0xFFFFFFFF).withOpacity(0.9),
    const Color(0xFFF8F9FF).withOpacity(0.8),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Neutral Colors
const Color backgroundColor = Color(0xFFF8F9FF);
const Color surfaceColor = Color(0xFFFFFFFF);
const Color textPrimary = Color(0xFF1A1A2E);
const Color textSecondary = Color(0xFF6B6B7F);
const Color textMuted = Color(0xFF9B9BAA);

// Accent Colors
const Color accentGold = Color(0xFFFFD700);
const Color successGreen = Color(0xFF10B981);
const Color warningOrange = Color(0xFFF59E0B);
const Color errorRed = Color(0xFFEF4444);

// Glassmorphism
const Color glassBackground = Color(0xFFFFFFFF);
const double glassOpacity = 0.7;
const double glassBlur = 20.0;

// Typography
const TextStyle h1 = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 32,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.5,
  color: textPrimary,
);

const TextStyle h2 = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 28,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.3,
  color: textPrimary,
);

const TextStyle h3 = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 24,
  fontWeight: FontWeight.w600,
  color: textPrimary,
);

const TextStyle h4 = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: textPrimary,
);

const TextStyle bodyLarge = TextStyle(
  fontFamily: 'Inter',
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 1.5,
  color: textPrimary,
);

const TextStyle bodyMedium = TextStyle(
  fontFamily: 'Inter',
  fontSize: 14,
  fontWeight: FontWeight.w400,
  height: 1.5,
  color: textSecondary,
);

const TextStyle bodySmall = TextStyle(
  fontFamily: 'Inter',
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: textMuted,
);

const TextStyle buttonText = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 16,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.5,
  color: Colors.white,
);

const TextStyle caption = TextStyle(
  fontFamily: 'Inter',
  fontSize: 11,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.5,
  color: textMuted,
);

// Spacing
const double space2 = 2.0;
const double space4 = 4.0;
const double space6 = 6.0;
const double space8 = 8.0;
const double space10 = 10.0;
const double space12 = 12.0;
const double space16 = 16.0;
const double space20 = 20.0;
const double space24 = 24.0;
const double space32 = 32.0;
const double space40 = 40.0;
const double space48 = 48.0;

// Radius
const double radiusSmall = 12.0;
const double radiusMedium = 16.0;
const double radiusLarge = 24.0;
const double radiusXLarge = 32.0;

// Shadows
const List<BoxShadow> softShadow = [
  BoxShadow(
    color: Color(0x10000000),
    offset: Offset(0, 4),
    blurRadius: 20,
  ),
];

const List<BoxShadow> cardShadow = [
  BoxShadow(
    color: Color(0x08000000),
    offset: Offset(0, 8),
    blurRadius: 30,
  ),
];

const List<BoxShadow> floatingShadow = [
  BoxShadow(
    color: Color(0x15000000),
    offset: Offset(0, 12),
    blurRadius: 40,
  ),
];
