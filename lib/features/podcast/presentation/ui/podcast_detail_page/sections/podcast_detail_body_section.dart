part of '../podcast_detail_page.dart';

class _PodcastDetailBodySection extends ConsumerWidget {
  const _PodcastDetailBodySection({required this.episode});

  final PodcastEpisode episode;

  void _playEpisode(
    BuildContext context,
    WidgetRef ref,
    PodcastEpisode episode,
  ) {
    unawaited(ref.read(podcastPlayerProvider.notifier).play(episode));
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const PodcastPlayerSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Badge, Season Info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    episode.category.tr().toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Season {} • Episode {}'
                      .tr(
                        args: [
                          episode.seasonNumber.toString(),
                          episode.episodeNumber.toString(),
                        ],
                      )
                      .toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              episode.title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            // Publish Date and Duration
            Text(
              'Published on {} • {}'.tr(
                args: [
                  DateTimeUtils.formatDate(episode.publishDate),
                  '{} minutes'.tr(
                    args: [
                      (episode.durationSeconds ~/ 60).toString(),
                    ],
                  ),
                ],
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Large custom Play Button
            Builder(
              builder: (context) {
                final playerState = ref.watch(podcastPlayerProvider);
                final isCurrentEpisode =
                    playerState.currentEpisode?.id == episode.id;
                final isPlaying = isCurrentEpisode && playerState.isPlaying;

                return ElevatedButton.icon(
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 28,
                  ),
                  label: Text(
                    (isPlaying
                            ? 'Pause Episode'
                            : isCurrentEpisode
                            ? 'Resume Episode'
                            : 'Play Episode')
                        .tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () => isPlaying
                      ? ref
                            .read(podcastPlayerProvider.notifier)
                            .togglePlayback()
                      : _playEpisode(context, ref, episode),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // Episode Description Markdown Header
            Text(
              'Episode Description'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            // Episode Markdown Body
            BenaiahMarkdown(data: episode.description),
            const SizedBox(height: 32),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
