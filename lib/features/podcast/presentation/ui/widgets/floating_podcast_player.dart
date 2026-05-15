import 'dart:async';
import 'package:benaiah_app/core/widgets/benaiah_network_image.dart';
import 'package:benaiah_app/features/podcast/presentation/providers/podcast_player_notifier.dart';
import 'package:benaiah_app/features/podcast/presentation/ui/widgets/podcast_player_sheet.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FloatingPodcastPlayer extends ConsumerWidget {
  const FloatingPodcastPlayer({super.key});

  void _openDetailedPlayer(BuildContext context) {
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
    final playerState = ref.watch(podcastPlayerProvider);
    final episode = playerState.currentEpisode;

    if (episode == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: GestureDetector(
        onTap: () => _openDetailedPlayer(context),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 60,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest.withAlpha(240)
                : theme.colorScheme.surfaceContainerLowest.withAlpha(240),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 90 : 40),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black12,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      // Play/Pause icon button
                      GestureDetector(
                        onTap: () => ref
                            .read(podcastPlayerProvider.notifier)
                            .togglePlayback(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: playerState.isBuffering
                              ? const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  playerState.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: theme.colorScheme.onPrimary,
                                  size: 22,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Episode image artwork
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(19),
                          color: Colors.grey.withAlpha(50),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: episode.imageUrl.isNotEmpty
                            ? BenaiahNetworkImage(
                                imageUrl: episode.imageUrl,
                              )
                            : Icon(
                                Icons.podcasts_rounded,
                                color: theme.colorScheme.primary,
                                size: 18,
                              ),
                      ),
                      const SizedBox(width: 12),
                      // Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              episode.title,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
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
                      const SizedBox(width: 8),
                      // Maximize indicator
                      Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: theme.colorScheme.primary.withAlpha(140),
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              // Tiny bottom progress indicator bar
              SizedBox(
                height: 3,
                child: LinearProgressIndicator(
                  value: playerState.progress,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
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
