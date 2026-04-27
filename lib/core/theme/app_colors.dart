import 'package:flutter/material.dart';

abstract class AppColors {
  // Common
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const grey = Color(0xFF9E9E9E);
  static const lightGrey = Color(0xFFF5F5F5);
  static const darkGrey = Color(0xFF212121);

  // Light Theme (Mainly White background, Black accents)
  static const Color lightPrimary = black;
  static const Color lightOnPrimary = white;
  static const Color lightBackground = white;
  static const Color lightOnBackground = black;
  static const Color lightSurface = white;
  static const Color lightOnSurface = black;
  static const lightError = Color(0xFFB3261E);

  // Dark Theme (Mainly Black background, White accents)
  static const Color darkPrimary = white;
  static const Color darkOnPrimary = black;
  static const Color darkBackground = black;
  static const Color darkOnBackground = white;
  static const Color darkSurface = darkGrey;
  static const Color darkOnSurface = white;
  static const darkError = Color(0xFFF2B8B5);
}
