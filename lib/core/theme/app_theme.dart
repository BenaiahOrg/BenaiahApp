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
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: titleFontFamily,
      ),
      headlineSmall: base.headlineSmall?.copyWith(fontFamily: titleFontFamily),
      titleLarge: base.titleLarge?.copyWith(fontFamily: titleFontFamily),
      titleMedium: base.titleMedium?.copyWith(fontFamily: titleFontFamily),
    );
  }

  /// The monochrome variant fills every Material role (containers, outlines,
  /// onSurfaceVariant for secondary text) from a neutral palette, so screens
  /// never need a raw grey. The brand's pure black and white are then pinned
  /// on top.
  static ColorScheme _colorScheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ColorScheme.fromSeed(
      seedColor: AppColors.black,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
    ).copyWith(
      primary: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
      onPrimary: isDark ? AppColors.darkOnPrimary : AppColors.lightOnPrimary,
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      onSurface: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
      error: isDark ? AppColors.darkError : AppColors.lightError,
    );
  }

  static ThemeData light(String fontFamily) =>
      _build(Brightness.light, fontFamily);

  static ThemeData dark(String fontFamily) =>
      _build(Brightness.dark, fontFamily);

  static ThemeData _build(Brightness brightness, String fontFamily) {
    final isDark = brightness == Brightness.dark;
    final scheme = _colorScheme(brightness);
    final background = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: GoogleFonts.lexend().fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: _buildTextTheme(fontFamily).apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      // One elevation system for every tappable card: a soft offset shadow
      // and no hairline border.
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withAlpha(isDark ? 90 : 40),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: scheme.outlineVariant,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.lightGrey,
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
          borderSide: BorderSide(color: scheme.primary),
        ),
      ),
    );
  }
}
