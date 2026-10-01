part of '../podcast_detail_page.dart';

class _PodcastDetailHostsSection extends StatelessWidget {
  const _PodcastDetailHostsSection({required this.episode});

  final PodcastEpisode episode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return SliverPadding(
      padding: AppLayout.readingInsets(context),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              episode.hosts.length > 1 ? 'Hosts'.tr() : 'Host'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...episode.hosts.map((host) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  child: InkWell(
                    onTap: () {
                      unawaited(
                        context.push(
                          RouteNames.podcastHostDetail.replaceAll(
                            ':hostId',
                            host.id,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: BenaiahNetworkImage(
                              imageUrl: host.imageUrl,
                              width: 50,
                              height: 50,
                            ),
                          ),
                          const SizedBox(width: 16),
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
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: muted,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: muted),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
