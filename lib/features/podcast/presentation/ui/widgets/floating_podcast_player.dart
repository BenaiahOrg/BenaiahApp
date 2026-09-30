import 'dart:async';

import 'package:benaiah_app/core/widgets/benaiah_network_image.dart';
import 'package:benaiah_app/features/podcast/presentation/providers/podcast_player_notifier.dart';
import 'package:benaiah_app/features/podcast/presentation/ui/widgets/podcast_player_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FloatingPodcastPlayer extends ConsumerStatefulWidget {
  const FloatingPodcastPlayer({super.key});

  @override
  ConsumerState<FloatingPodcastPlayer> createState() =>
      _FloatingPodcastPlayerState();
}

class _FloatingPodcastPlayerState extends ConsumerState<FloatingPodcastPlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  );

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(podcastPlayerProvider);
    final episode = playerState.currentEpisode;

    if (episode == null) {
      return const SizedBox.shrink();
    }

    // The artwork turns while audio plays, unless the system asks for
    // reduced motion.
    final spin =
        playerState.isPlaying && !MediaQuery.disableAnimationsOf(context);
    if (spin && !_rotationController.isAnimating) {
      _rotationController.repeat();
    } else if (!spin && _rotationController.isAnimating) {
      _rotationController.stop();
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final notifier = ref.read(podcastPlayerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      // Shadow only: the bar floats over content, and a hairline border on
      // top of the shadow would repeat the same edge.
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 90 : 40),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: isDark
              ? scheme.surfaceContainerHighest.withAlpha(240)
              : scheme.surfaceContainerLowest.withAlpha(240),
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => unawaited(showPodcastPlayerSheet(context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Grows with the reader's font size instead of clipping.
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 61),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      children: [
                        // Tapping the artwork toggles playback instead of
                        // opening the player sheet.
                        Tooltip(
                          message: (playerState.isPlaying ? 'Pause' : 'Play')
                              .tr(),
                          child: InkResponse(
                            onTap: () => unawaited(notifier.togglePlayback()),
                            radius: 26,
                            child: SizedBox.square(
                              dimension: 48,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  RotationTransition(
                                    turns: _rotationController,
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: scheme.surfaceContainerHighest,
                                        border: Border.all(
                                          color: scheme.outlineVariant,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: episode.imageUrl.isNotEmpty
                                          ? BenaiahNetworkImage(
                                              imageUrl: episode.imageUrl,
                                              width: 44,
                                              height: 44,
                                            )
                                          : Icon(
                                              Icons.podcasts_rounded,
                                              color: scheme.onSurfaceVariant,
                                              size: 20,
                                            ),
                                    ),
                                  ),
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: scheme.primary.withAlpha(200),
                                      shape: BoxShape.circle,
                                    ),
                                    child: playerState.isBuffering
                                        ? Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: CircularProgressIndicator(
                                              color: scheme.onPrimary,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(
                                            playerState.isPlaying
                                                ? Icons.pause_rounded
                                                : Icons.play_arrow_rounded,
                                            color: scheme.onPrimary,
                                            size: 16,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  episode.title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  episode.hosts.map((h) => h.name).join(', '),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Stops playback, which also hides this player.
                        IconButton(
                          onPressed: () => unawaited(notifier.reset()),
                          icon: const Icon(Icons.close_rounded, size: 20),
                          color: scheme.onSurfaceVariant,
                          tooltip: 'Close'.tr(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: playerState.progress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
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
