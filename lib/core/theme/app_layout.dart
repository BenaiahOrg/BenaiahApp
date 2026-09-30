import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Width breakpoints and measures shared by every screen.
abstract class AppLayout {
  /// Material's compact/medium window-size boundary. At or above it the app
  /// trades the bottom navigation bar for a navigation rail.
  static const double mediumWidth = 600;

  /// Longest comfortable measure for body text: roughly 70 characters at the
  /// reading size, so tablets don't stretch articles edge to edge.
  static const double readingMaxWidth = 680;

  /// Side padding that centers a page's content in a [readingMaxWidth]
  /// column on wide screens, and is never less than [min] on phones.
  static EdgeInsets readingInsets(BuildContext context, {double min = 24}) =>
      readingInsetsForWidth(MediaQuery.sizeOf(context).width, min: min);

  /// [readingInsets] for a region narrower than the window, such as a tab
  /// beside the navigation rail.
  static EdgeInsets readingInsetsForWidth(double width, {double min = 24}) {
    final side = math.max(min, (width - readingMaxWidth) / 2);
    return EdgeInsets.symmetric(horizontal: side);
  }
}
