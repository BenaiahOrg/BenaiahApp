import 'package:flutter/material.dart';

abstract class AppColors {
  // Common
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const grey = Color(0xFF9E9E9E);
  static const lightGrey = Color(0xFFF5F5F5);
  static const darkGrey = Color(0xFF212121);

  // Light Theme (Mainly White background, Black accents)
  static const lightPrimary = black;
  static const lightOnPrimary = white;
  static const lightBackground = white;
  static const lightOnBackground = black;
  static const lightSurface = white;
  static const lightOnSurface = black;
  static const lightError = Color(0xFFB3261E);

  // Dark Theme (Mainly Black background, White accents)
  static const darkPrimary = white;
  static const darkOnPrimary = black;
  static const darkBackground = black;
  static const darkOnBackground = white;
  static const darkSurface = darkGrey;
  static const darkOnSurface = white;
  static const darkError = Color(0xFFF2B8B5);
}
