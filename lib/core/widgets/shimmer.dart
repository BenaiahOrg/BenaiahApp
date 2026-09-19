import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart' as shimmer_pkg;

/// Wraps skeleton placeholder content in the app's one shimmer effect (the
/// `shimmer` package, already used by `BenaiahNetworkImage`'s own loading
/// placeholder) so a screen full of `ShimmerBox`es sweeps together.
class Shimmer extends StatelessWidget {
  const Shimmer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return shimmer_pkg.Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : Colors.black12,
      highlightColor: isDark ? Colors.white24 : Colors.black26,
      child: child,
    );
  }
}

/// A single placeholder box. Must be a descendant of [Shimmer].
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    this.width,
    this.height,
    this.borderRadius = 8,
    super.key,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Mirrors `ContentListTile`'s exact geometry (12px padding on every side,
/// the same image size, gap, and text-column layout) so the loading state
/// doesn't visibly jump when the real content swaps in.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({this.imageSize = 80, super.key});

  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ShimmerBox(width: imageSize, height: imageSize),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(height: 16, borderRadius: 4),
                  const SizedBox(height: 8),
                  ShimmerBox(
                    width: imageSize * 1.5,
                    height: 12,
                    borderRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 22),
          ],
        ),
      ),
    );
  }
}

/// A vertical run of [SkeletonListTile]s, for list-shaped loading states.
class SkeletonList extends StatelessWidget {
  const SkeletonList({this.itemCount = 5, this.imageSize = 80, super.key});

  final int itemCount;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) =>
            SkeletonListTile(imageSize: imageSize),
      ),
    );
  }
}

/// Mirrors `_PodcastEpisodeListTile`'s geometry: a fixed-height card with a
/// square image flush against the card edge (no inner padding around it),
/// unlike `ContentListTile`'s padded layout.
class SkeletonPodcastTile extends StatelessWidget {
  const SkeletonPodcastTile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(12) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            ShimmerBox(
              width: 100,
              height: 100,
              borderRadius: 0,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 90, height: 10, borderRadius: 4),
                    SizedBox(height: 10),
                    ShimmerBox(height: 15, borderRadius: 4),
                    SizedBox(height: 8),
                    ShimmerBox(width: 120, height: 12, borderRadius: 4),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

/// Mirrors the plain (card-less) `ListTile` rows used by the search
/// delegates: a small square image, default `ListTile` padding, no card
/// background or border.
class SkeletonPlainTile extends StatelessWidget {
  const SkeletonPlainTile({this.imageSize = 50, super.key});

  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ShimmerBox(width: imageSize, height: imageSize),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(height: 15, borderRadius: 4),
                const SizedBox(height: 8),
                ShimmerBox(
                  width: imageSize * 1.8,
                  height: 12,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A vertical run of [SkeletonPlainTile]s, for search-result loading states.
class SkeletonPlainList extends StatelessWidget {
  const SkeletonPlainList({this.itemCount = 6, this.imageSize = 50, super.key});

  final int itemCount;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: itemCount,
        itemBuilder: (context, index) =>
            SkeletonPlainTile(imageSize: imageSize),
      ),
    );
  }
}
