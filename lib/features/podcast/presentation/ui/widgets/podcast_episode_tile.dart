import 'dart:async';

import 'package:benaiah_app/core/utils/date_time_utils.dart';
import 'package:benaiah_app/core/widgets/benaiah_network_image.dart';
import 'package:benaiah_app/features/podcast/domain/entities/podcast_episode.dart';
import 'package:benaiah_app/features/podcast/presentation/providers/podcast_player_notifier.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Category, publish date and length on one line: "Faith • Jan 12, 2026 •
/// 32m". Shared by the episode rows and the Podcasts tab's banner.
String podcastEpisodeMeta(PodcastEpisode episode) => [
  if (episode.category.isNotEmpty) episode.category.tr(),
  DateTimeUtils.formatDate(episode.publishDate),
  DateTimeUtils.formatDuration(episode.durationSeconds),
].join(' • ');

/// The image-title-hosts-meta row shared by every screen that lists podcast
/// episodes (the Podcasts tab, a host's profile page).
class PodcastEpisodeTile extends ConsumerWidget {
  const PodcastEpisodeTile({
    required this.episode,
    required this.onTap,
    super.key,
  });

  static const _imageSize = 100.0;

  final PodcastEpisode episode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final hosts = episode.hosts.map((h) => h.name).join(', ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          onTap: onTap,
          // The text sets the row's height, so it grows with the reader's
          // font size instead of clipping; the artwork fills whatever height
          // that is, flush against the card's leading edge.
          child: Stack(
            children: [
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                width: _imageSize,
                child: BenaiahNetworkImage(
                  imageUrl: episode.imageUrl,
                  width: _imageSize,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: _imageSize),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: _imageSize),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            12,
                            10,
                            4,
                            10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                episode.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (hosts.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  hosts,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: muted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                podcastEpisodeMeta(episode),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: muted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 4),
                        child: _PlayButton(episode: episode),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Plays this episode, or pauses it when it is the one playing. Filled while
/// the episode is loaded in the player.
class _PlayButton extends ConsumerWidget {
  const _PlayButton({required this.episode});

  final PodcastEpisode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only the current episode and play state matter here, not every
    // position tick.
    final (currentId, playing) = ref.watch(
      podcastPlayerProvider.select(
        (s) => (s.currentEpisode?.id, s.isPlaying),
      ),
    );
    final isCurrentEpisode = currentId == episode.id;
    final isPlaying = isCurrentEpisode && playing;

    void onPressed() {
      final notifier = ref.read(podcastPlayerProvider.notifier);
      unawaited(isPlaying ? notifier.togglePlayback() : notifier.play(episode));
    }

    final icon = Icon(
      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
    );
    final tooltip = (isPlaying ? 'Pause' : 'Play').tr();

    if (isCurrentEpisode) {
      return IconButton.filled(
        onPressed: onPressed,
        icon: icon,
        tooltip: tooltip,
      );
    }
    return IconButton.outlined(
      onPressed: onPressed,
      icon: icon,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    );
  }
}
