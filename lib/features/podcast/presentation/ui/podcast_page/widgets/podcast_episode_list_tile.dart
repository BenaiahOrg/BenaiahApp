part of '../podcast_page.dart';

class _PodcastEpisodeListTile extends ConsumerWidget {
  const _PodcastEpisodeListTile({
    required this.episode,
    required this.onTap,
  });

  final PodcastEpisode episode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withAlpha(12) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 30 : 10),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withAlpha(5),
            ),
          ),
          child: Row(
            children: [
              // Left Image
              Container(
                width: 100,
                height: 100,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: BenaiahNetworkImage(
                  imageUrl: episode.imageUrl,
                ),
              ),
              const SizedBox(width: 12),
              // Text details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              episode.category.tr().toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${DateTimeUtils.formatDate(episode.publishDate)} • ${DateTimeUtils.formatDuration(
                              episode.durationSeconds,
                            )}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        episode.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        episode.hosts.map((h) => h.name).join(', '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              // Fast play icon button
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Builder(
                  builder: (context) {
                    final playerState = ref.watch(podcastPlayerProvider);
                    final isCurrentEpisode =
                        playerState.currentEpisode?.id == episode.id;
                    final isPlaying = isCurrentEpisode && playerState.isPlaying;

                    return Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrentEpisode
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: isCurrentEpisode
                              ? theme.colorScheme.primary
                              : isDark
                                  ? Colors.white24
                                  : Colors.black12,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 16,
                          color: isCurrentEpisode
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.primary,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (isPlaying) {
                            unawaited(
                              ref
                                  .read(podcastPlayerProvider.notifier)
                                  .togglePlayback(),
                            );
                          } else {
                            unawaited(
                              ref
                                  .read(podcastPlayerProvider.notifier)
                                  .play(episode),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
