import 'package:benaiah_app/gen/assets.gen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BenaiahNetworkImage extends StatelessWidget {
  const BenaiahNetworkImage({
    required this.imageUrl,
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return errorWidget ?? _buildFallback(context);
    }

    // Decode at roughly display resolution instead of the source's full
    // size. Every caller renders these at a few hundred px at most, but
    // without this the decoder was working at whatever resolution the CMS
    // served, which is the main cause of jank on image-heavy screens (home,
    // graphics grid) and on cold start.
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = width != null && width!.isFinite
        ? (width! * dpr).round()
        : (MediaQuery.sizeOf(context).width * dpr).round();
    final cacheHeight = height != null && height!.isFinite
        ? (height! * dpr).round()
        : null;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      fadeInDuration: const Duration(milliseconds: 150),
      fadeOutDuration: Duration.zero,
      placeholderFadeInDuration: Duration.zero,
      placeholder: (context, url) {
        return placeholder ?? _buildLoadingPlaceholder(context);
      },
      errorWidget: (context, url, error) {
        return errorWidget ?? _buildFallback(context);
      },
    );
  }

  Widget _buildLoadingPlaceholder(
    BuildContext context,
  ) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest
          .withAlpha(
            100,
          ),
      highlightColor: Theme.of(context).colorScheme.surfaceContainerHighest
          .withAlpha(
            200,
          ),
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Opacity(
          opacity: 0.3,
          child: Image.asset(
            isDark
                ? Assets.images.logoWhite.path
                : Assets.images.logoBlack.path,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
