import 'package:benaiah_app/core/theme/app_colors.dart';
import 'package:benaiah_app/core/theme/app_text_theme.dart';
import 'package:flutter/material.dart';

abstract class AppTheme {
  static ThemeData light(String fontFamily) => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: fontFamily,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      error: AppColors.lightError,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: AppTextTheme.textTheme.apply(
      bodyColor: AppColors.lightOnBackground,
      displayColor: AppColors.lightOnBackground,
      fontFamily: fontFamily,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightOnBackground,
      elevation: 0,
      centerTitle: true,
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
    fontFamily: fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      surface: AppColors.darkSurface,
      error: AppColors.darkError,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: AppTextTheme.textTheme.apply(
      bodyColor: AppColors.darkOnBackground,
      displayColor: AppColors.darkOnBackground,
      fontFamily: fontFamily,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkOnSurface,
      elevation: 0,
      centerTitle: true,
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
