// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/Benaiah_am.ttf
  String get benaiahAm => 'assets/fonts/Benaiah_am.ttf';

  /// File path: assets/fonts/Benaiah_en.ttf
  String get benaiahEn => 'assets/fonts/Benaiah_en.ttf';

  /// List of all assets
  List<String> get values => [benaiahAm, benaiahEn];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/app_icon_black.png
  AssetGenImage get appIconBlack =>
      const AssetGenImage('assets/icons/app_icon_black.png');

  /// File path: assets/icons/app_icon_white.png
  AssetGenImage get appIconWhite =>
      const AssetGenImage('assets/icons/app_icon_white.png');

  /// List of all assets
  List<AssetGenImage> get values => [appIconBlack, appIconWhite];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/logo_black.png
  AssetGenImage get logoBlack =>
      const AssetGenImage('assets/images/logo_black.png');

  /// File path: assets/images/logo_white.png
  AssetGenImage get logoWhite =>
      const AssetGenImage('assets/images/logo_white.png');

  /// List of all assets
  List<AssetGenImage> get values => [logoBlack, logoWhite];
}

class $AssetsTranslationsGen {
  const $AssetsTranslationsGen();

  /// File path: assets/translations/langs.csv
  String get langs => 'assets/translations/langs.csv';

  /// List of all assets
  List<String> get values => [langs];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsTranslationsGen translations = $AssetsTranslationsGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
