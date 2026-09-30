part of '../podcast_page.dart';

/// The newest episode, given a full-width card above the list. Its size and
/// position mark it out; it carries no "featured" badge.
class _FeaturedEpisodeBanner extends StatelessWidget {
  const _FeaturedEpisodeBanner({
    required this.episode,
    required this.onTap,
    required this.insets,
  });

  final PodcastEpisode episode;
  final VoidCallback onTap;
  final EdgeInsets insets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return SliverPadding(
      padding: insets.copyWith(top: 16, bottom: 24),
      sliver: SliverToBoxAdapter(
        child: Card(
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: BenaiahNetworkImage(
                    imageUrl: episode.imageUrl,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        episode.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        podcastEpisodeMeta(episode),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        episode.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: muted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
