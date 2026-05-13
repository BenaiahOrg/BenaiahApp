import 'package:benaiah_app/gen/assets.gen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return placeholder ??
            _buildLoadingPlaceholder(context, downloadProgress);
      },
      errorWidget: (context, url, error) {
        return errorWidget ?? _buildFallback(context);
      },
    );
  }

  Widget _buildLoadingPlaceholder(
    BuildContext context,
    DownloadProgress downloadProgress,
  ) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withAlpha(100),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          value: downloadProgress.progress,
        ),
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
