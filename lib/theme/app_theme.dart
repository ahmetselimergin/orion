import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // 2026 Ultra-Modern Shadcn/Linear Obsidian Dark Palette
  static const Color darkBackground = Color(0xFF090D16); // Deepest Obsidian Slate
  static const Color darkSurface = Color(0xFF111726);    // Translucent Slate Surface
  static const Color darkCard = Color(0xFF182030);       // Input & Card Backdrop
  static const Color darkBorder = Color(0xFF232D42);     // Subtle Border
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Crisp White Text
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Muted Slate

  // 2026 Light Palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Vibrant Accents (Shadcn Indigo & Cyan)
  static const Color primary = Color(0xFF6366F1);       // Electric Indigo
  static const Color primaryGlow = Color(0xFF818CF8);
  static const Color accent = Color(0xFF06B6D4);        // Cyan
  static const Color violet = Color(0xFFA855F7);        // Violet

  // Status Tints
  static const Color backlog = Color(0xFF64748B);
  static const Color todo = Color(0xFF3B82F6);
  static const Color inProgress = Color(0xFFF59E0B);
  static const Color inReview = Color(0xFFA855F7);
  static const Color done = Color(0xFF10B981);
}

class AppTheme {
  static ThemeData get darkTheme {
    final baseText = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.darkSurface,
      ),
      dividerColor: AppColors.darkBorder.withValues(alpha: 0.5),
      dividerTheme: DividerThemeData(
        color: AppColors.darkBorder.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.darkBorder.withValues(alpha: 0.6), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.darkBorder.withValues(alpha: 0.6), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.darkBorder.withValues(alpha: 0.6), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide(color: AppColors.darkBorder.withValues(alpha: 0.6), width: 1),
          foregroundColor: AppColors.darkTextPrimary,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 16,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.darkBorder.withValues(alpha: 0.6), width: 1),
        ),
      ),
      textTheme: baseText.apply(
        bodyColor: AppColors.darkTextPrimary,
        displayColor: AppColors.darkTextPrimary,
      ),
    );
  }

  static ThemeData get lightTheme {
    final baseText = GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme);

    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.lightSurface,
      ),
      dividerColor: AppColors.lightBorder,
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
          foregroundColor: AppColors.lightTextPrimary,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 16,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      textTheme: baseText.apply(
        bodyColor: AppColors.lightTextPrimary,
        displayColor: AppColors.lightTextPrimary,
      ),
    );
  }
}
