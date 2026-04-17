import 'package:flutter/material.dart';

class ExFuturisticTheme {
  static const Color bg = Color(0xFF040706);
  static const Color panel = Color(0xFF0C1110);
  static const Color panelSoft = Color(0xFF121918);
  static const Color panelElevated = Color(0xFF171F1D);
  static const Color stroke = Color(0x1FFFFFFF);
  static const Color primary = Color(0xFF0BFF95);
  static const Color primarySoft = Color(0xFF7BFFC7);
  static const Color cyan = Color(0xFF8CF8FF);
  static const Color amber = Color(0xFFFFD465);
  static const Color blue = Color(0xFF4F72FF);
  static const Color purple = Color(0xFFA86BFF);
  static const Color danger = Color(0xFFFF6B7A);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF90A19C);
  static const Color textMuted = Color(0xFF61726E);

  static LinearGradient glassGradient({
    Color top = const Color(0x14FFFFFF),
    Color bottom = const Color(0x08FFFFFF),
  }) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[top, bottom],
    );
  }

  static LinearGradient neonGradient({
    Color start = primary,
    Color end = primarySoft,
  }) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[start, end],
    );
  }

  static List<BoxShadow> glow({
    Color color = primary,
    double opacity = 0.18,
    double blur = 28,
    double spread = 0,
  }) {
    return <BoxShadow>[
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: blur,
        spreadRadius: spread,
      ),
    ];
  }

  static TextStyle get overline => const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.2,
        color: textMuted,
      );

  static TextStyle get sectionTitle => const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );
}
