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
    required this.onTap,
    this.subtitle,
    this.imageSize = 80,
    super.key,
  });

  final String imageUrl;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = this.subtitle;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: InkWell(
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
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.article_outlined,
                            color: theme.colorScheme.onSurfaceVariant,
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
