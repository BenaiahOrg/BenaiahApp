import 'package:flutter/material.dart';

class ResponsiveConfig {
  const ResponsiveConfig._();

  static double _designWidth = 375;
  static double _designHeight = 812;
  static BuildContext? _context;

  static void init({
    required double designWidth,
    required double designHeight,
  }) {
    _designWidth = designWidth;
    _designHeight = designHeight;
  }

  static BuildContext? get context => _context;
  static set context(BuildContext context) => _context = context;

  static double get _screenWidth =>
      MediaQuery.sizeOf(_context!).width;

  static double get _screenHeight =>
      MediaQuery.sizeOf(_context!).height;

  static double get designWidth => _designWidth;
  static double get designHeight => _designHeight;
  static double get scaleWidth => _screenWidth / _designWidth;
  static double get scaleHeight => _screenHeight / _designHeight;
}

extension ResponsiveExtension on num {
  /// Scales by screen width (e.g. `16.w` for widths, padding, margins).
  double get w => this * ResponsiveConfig.scaleWidth;

  /// Scales by screen height (e.g. `24.h` for vertical spacing).
  double get h => this * ResponsiveConfig.scaleHeight;

  /// Scales font size using width ratio (consistent across devices).
  double get sp => this * ResponsiveConfig.scaleWidth;
}
