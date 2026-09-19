import 'package:benaiah_app/core/widgets/benaiah_network_image.dart';
import 'package:flutter/material.dart';

/// The image-title-subtitle-chevron row shared by every "browse this list of
/// content" screen (a series' topics, an author's articles). Uses a plain
/// [Row] with uniform padding on every side instead of [ListTile], whose
/// default vertical-centering leaves a lopsided gap when the leading image
/// is much taller than the two lines of text next to it.
class ContentListTile extends StatelessWidget {
  const ContentListTile({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.imageSize = 80,
    super.key,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        shadowColor: Colors.black.withAlpha(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.isNotEmpty
                      ? BenaiahNetworkImage(
                          imageUrl: imageUrl,
                          width: imageSize,
                          height: imageSize,
                        )
                      : Container(
                          width: imageSize,
                          height: imageSize,
                          color: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.article,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
