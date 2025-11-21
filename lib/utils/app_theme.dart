import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern, mature color palette - calming and professional
  static const Color primaryBlue = Color(0xFF4A90E2); // Soft, calming blue
  static const Color primaryGreen = Color(0xFF52C9A2); // Fresh, health-oriented green
  static const Color accentPurple = Color(0xFF9B8AFB); // Modern accent purple
  static const Color neutralGray = Color(0xFF6C757D);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  
  // Dark theme colors
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceDark = Color(0xFF16213E);
  static const Color textPrimaryDark = Color(0xFFE8E8E8);
  static const Color textSecondaryDark = Color(0xFFB8B8B8);

  static ThemeData get lightTheme {
    // Get Noto Sans font family for fallback
    final notoSansFamily = GoogleFonts.notoSans().fontFamily;
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamilyFallback: [
        if (notoSansFamily != null) notoSansFamily,
        'Noto Sans',
        'sans-serif',
      ],
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryGreen,
        tertiary: accentPurple,
        surface: surfaceLight,
        background: backgroundLight,
        error: const Color(0xFFE74C3C),
      ),
      scaffoldBackgroundColor: backgroundLight,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        color: surfaceLight,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: surfaceLight,
        foregroundColor: textPrimary,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.poppins(color: textPrimary),
        bodyMedium: GoogleFonts.poppins(color: textPrimary),
        bodySmall: GoogleFonts.poppins(color: textSecondary, fontSize: 12),
        labelLarge: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w500),
        labelMedium: GoogleFonts.poppins(color: textSecondary),
        labelSmall: GoogleFonts.poppins(color: textSecondary, fontSize: 11),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData get darkTheme {
    // Get Noto Sans font family for fallback
    final notoSansFamily = GoogleFonts.notoSans().fontFamily;
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamilyFallback: [
        if (notoSansFamily != null) notoSansFamily,
        'Noto Sans',
        'sans-serif',
      ],
      colorScheme: ColorScheme.dark(
        primary: primaryBlue,
        secondary: primaryGreen,
        tertiary: accentPurple,
        surface: surfaceDark,
        background: backgroundDark,
        error: const Color(0xFFE74C3C),
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade800, width: 1),
        ),
        color: surfaceDark,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: surfaceDark,
        foregroundColor: textPrimaryDark,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(color: textPrimaryDark, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.poppins(color: textPrimaryDark, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.poppins(color: textPrimaryDark, fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.poppins(color: textPrimaryDark, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.poppins(color: textPrimaryDark, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.poppins(color: textPrimaryDark, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.poppins(color: textPrimaryDark, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.poppins(color: textPrimaryDark, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.poppins(color: textPrimaryDark, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.poppins(color: textPrimaryDark),
        bodyMedium: GoogleFonts.poppins(color: textPrimaryDark),
        bodySmall: GoogleFonts.poppins(color: textSecondaryDark, fontSize: 12),
        labelLarge: GoogleFonts.poppins(color: textPrimaryDark, fontWeight: FontWeight.w500),
        labelMedium: GoogleFonts.poppins(color: textSecondaryDark),
        labelSmall: GoogleFonts.poppins(color: textSecondaryDark, fontSize: 11),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// Mood color mapping
class MoodColors {
  static const Map<String, Color> colors = {
    'Excellent': Color(0xFF52C9A2),
    'Good': Color(0xFF4A90E2),
    'Okay': Color(0xFFF39C12),
    'Bad': Color(0xFFE67E22),
    'Terrible': Color(0xFFE74C3C),
  };
  
  static Color getColor(String mood) {
    return colors[mood] ?? AppTheme.neutralGray;
  }
}

