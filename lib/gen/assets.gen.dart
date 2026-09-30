// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

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

  /// Directory path: assets/icons/social
  $AssetsIconsSocialGen get social => const $AssetsIconsSocialGen();

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

class $AssetsIconsSocialGen {
  const $AssetsIconsSocialGen();

  /// File path: assets/icons/social/contact.svg
  SvgGenImage get contact =>
      const SvgGenImage('assets/icons/social/contact.svg');

  /// File path: assets/icons/social/email.svg
  SvgGenImage get email => const SvgGenImage('assets/icons/social/email.svg');

  /// File path: assets/icons/social/facebook.svg
  SvgGenImage get facebook =>
      const SvgGenImage('assets/icons/social/facebook.svg');

  /// File path: assets/icons/social/instagram.svg
  SvgGenImage get instagram =>
      const SvgGenImage('assets/icons/social/instagram.svg');

  /// File path: assets/icons/social/linkedin.svg
  SvgGenImage get linkedin =>
      const SvgGenImage('assets/icons/social/linkedin.svg');

  /// File path: assets/icons/social/telegram.svg
  SvgGenImage get telegram =>
      const SvgGenImage('assets/icons/social/telegram.svg');

  /// File path: assets/icons/social/threads.svg
  SvgGenImage get threads =>
      const SvgGenImage('assets/icons/social/threads.svg');

  /// File path: assets/icons/social/x.svg
  SvgGenImage get x => const SvgGenImage('assets/icons/social/x.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
    contact,
    email,
    facebook,
    instagram,
    linkedin,
    telegram,
    threads,
    x,
  ];
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

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
