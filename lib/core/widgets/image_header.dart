import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pieces shared by the collapsing headers that put artwork behind the app
/// bar (series, topic and episode pages), so white text, the status bar and
/// the back button stay legible whatever the artwork looks like.

/// Darkens the top of the artwork (status bar, back button) and the bottom
/// (the title), leaving the middle of the picture untouched.
class ImageHeaderScrim extends StatelessWidget {
  const ImageHeaderScrim({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x8A000000),
            Color(0x00000000),
            Color(0x00000000),
            Color(0xDE000000),
          ],
          stops: [0, 0.3, 0.45, 1],
        ),
      ),
    );
  }
}

/// Light status bar icons while the header's artwork is showing, and the
/// theme's usual icons once it has collapsed to a plain bar.
class ImageHeaderStatusBar extends StatelessWidget {
  const ImageHeaderStatusBar({
    required this.overArtwork,
    required this.child,
    super.key,
  });

  final bool overArtwork;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overArtwork || isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: child,
    );
  }
}

/// The platform back button on a translucent disc, legible over artwork and
/// on the collapsed bar alike.
class ImageHeaderBackButton extends StatelessWidget {
  const ImageHeaderBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: IconButton(
        style: IconButton.styleFrom(
          backgroundColor: scheme.surface.withAlpha(200),
          foregroundColor: scheme.onSurface,
        ),
        icon: const BackButtonIcon(),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () => Navigator.maybePop(context),
      ),
    );
  }
}
