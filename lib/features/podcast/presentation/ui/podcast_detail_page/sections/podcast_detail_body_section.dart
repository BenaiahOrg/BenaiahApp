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
    unawaited(showPodcastPlayerSheet(context));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return SliverPadding(
      padding: AppLayout.readingInsets(context).copyWith(top: 24, bottom: 24),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The title leads; category and numbering follow as plain
            // metadata rather than a badge above it.
            Text(
              episode.title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              [
                if (episode.category.isNotEmpty) episode.category.tr(),
                'Season {} • Episode {}'.tr(
                  args: [
                    episode.seasonNumber.toString(),
                    episode.episodeNumber.toString(),
                  ],
                ),
              ].join(' • '),
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: 4),
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
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: 24),
            Builder(
              builder: (context) {
                final (currentId, playing) = ref.watch(
                  podcastPlayerProvider.select(
                    (s) => (s.currentEpisode?.id, s.isPlaying),
                  ),
                );
                final isCurrentEpisode = currentId == episode.id;
                final isPlaying = isCurrentEpisode && playing;

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
                );
              },
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            Text(
              'Episode Description'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            BenaiahMarkdown(data: episode.description),
            const SizedBox(height: 32),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
