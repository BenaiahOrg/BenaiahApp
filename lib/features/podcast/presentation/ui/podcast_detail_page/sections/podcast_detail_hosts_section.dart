part of '../podcast_detail_page.dart';

class _PodcastDetailHostsSection extends StatelessWidget {
  const _PodcastDetailHostsSection({required this.episode});

  final PodcastEpisode episode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Hosts profiles header
            Text(
              episode.hosts.length > 1 ? 'Hosts'.tr() : 'Host'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            // Hosts listing mapping
            ...episode.hosts.map((host) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.black.withAlpha(5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black.withAlpha(5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Host Image circular
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withAlpha(50),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: BenaiahNetworkImage(
                          imageUrl: host.imageUrl,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Name and Bio details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              host.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              host.bio,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            
            // Extra safe padding bottom
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
