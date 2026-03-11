import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color black = Color(0xFF000000);
  static const Color darkBg = Color(0xFF0A0A0A);
  static const Color cardDark = Color(0xFF1A1A1A);
  static const Color cardBorder = Color(0xFF2A2A2A);
  static const Color gold = Color(0xFFD4AF35);
  static const Color goldLight = Color(0xFFE8D48B);
  static const Color goldDark = Color(0xFFB8960F);
  static const Color white = Color(0xFFFFFFFF);
  static const Color greyLight = Color(0xFFAAAAAA);
  static const Color greyMid = Color(0xFF666666);
  static const Color greyDark = Color(0xFF333333);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.black,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.goldLight,
        surface: AppColors.cardDark,
        onPrimary: AppColors.black,
        onSecondary: AppColors.black,
        onSurface: AppColors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.gold,
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.white),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.white),
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.white),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.white),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.white),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.white),
          bodyLarge: TextStyle(fontSize: 16, color: AppColors.white),
          bodyMedium: TextStyle(fontSize: 14, color: AppColors.greyLight),
          bodySmall: TextStyle(fontSize: 12, color: AppColors.greyMid),
          labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.black,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          side: const BorderSide(color: AppColors.gold, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.greyMid),
        labelStyle: const TextStyle(color: AppColors.greyLight),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.greyMid,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder, width: 0.5),
        ),
        elevation: 0,
      ),
      useMaterial3: true,
    );
  }
}
