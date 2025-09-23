import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette
  static const Color darkBg = Color(0xFF111827);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color darkCard = Color(0xFF1F2937);
  static const Color lightText = Color(0xFFD1D5DB);
  static const Color mediumText = Color(0xFF9CA3AF);
  static const Color emerald = Color(0xFF10B981);
  static const Color rose = Color(0xFFF43F5E);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [darkBg, Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: primaryBlue,
      cardColor: darkCard,
      textTheme: _textTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      appBarTheme: _appBarTheme,
      expansionTileTheme: _expansionTileTheme,
    );
  }

  static TextTheme get _textTheme {
    return GoogleFonts.interTextTheme().copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: lightText,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: lightText,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: lightText,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightText,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: lightText,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: lightText,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: mediumText,
      ),
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: mediumText.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: mediumText.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      labelStyle: const TextStyle(color: mediumText),
      hintStyle: const TextStyle(color: mediumText),
    );
  }

  static AppBarTheme get _appBarTheme {
    return const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: lightText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: lightText),
    );
  }

  static ExpansionTileThemeData get _expansionTileTheme {
    return const ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      iconColor: lightText,
      collapsedIconColor: mediumText,
      textColor: lightText,
      collapsedTextColor: lightText,
    );
  }
}