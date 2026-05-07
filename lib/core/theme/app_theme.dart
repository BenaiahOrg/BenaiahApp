import 'package:benaiah_app/core/theme/app_colors.dart';
import 'package:benaiah_app/core/theme/app_text_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTheme {
  static TextTheme _buildTextTheme(String titleFontFamily) {
    final base = GoogleFonts.lexendTextTheme(AppTextTheme.textTheme);
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontFamily: titleFontFamily),
      displayMedium: base.displayMedium?.copyWith(fontFamily: titleFontFamily),
      displaySmall: base.displaySmall?.copyWith(fontFamily: titleFontFamily),
      headlineLarge: base.headlineLarge?.copyWith(fontFamily: titleFontFamily),
      headlineMedium: base.headlineMedium?.copyWith(fontFamily: titleFontFamily),
      headlineSmall: base.headlineSmall?.copyWith(fontFamily: titleFontFamily),
      titleLarge: base.titleLarge?.copyWith(fontFamily: titleFontFamily),
      titleMedium: base.titleMedium?.copyWith(fontFamily: titleFontFamily),
    );
  }

  static ThemeData light(String fontFamily) => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: GoogleFonts.lexend().fontFamily,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      error: AppColors.lightError,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: _buildTextTheme(fontFamily).apply(
      bodyColor: AppColors.lightOnBackground,
      displayColor: AppColors.lightOnBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightOnBackground,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightOnPrimary,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  static ThemeData dark(String fontFamily) => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.lexend().fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      surface: AppColors.darkSurface,
      error: AppColors.darkError,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: _buildTextTheme(fontFamily).apply(
      bodyColor: AppColors.darkOnBackground,
      displayColor: AppColors.darkOnBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkOnSurface,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkOnPrimary,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.darkPrimary),
      ),
    ),
  );
}
