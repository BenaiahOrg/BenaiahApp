import 'dart:async';
import 'package:benaiah_app/core/widgets/benaiah_network_image.dart';
import 'package:benaiah_app/features/podcast/presentation/providers/podcast_player_notifier.dart';
import 'package:benaiah_app/features/podcast/presentation/ui/widgets/podcast_player_sheet.dart';
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
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playerState = ref.read(podcastPlayerProvider);
      if (playerState.isPlaying) {
        _rotationController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    final playerState = ref.watch(podcastPlayerProvider);
    final episode = playerState.currentEpisode;

    if (episode == null) {
      return const SizedBox.shrink();
    }

    // Control rotation based on playback state
    if (playerState.isPlaying) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: GestureDetector(
        onTap: () => _openDetailedPlayer(context),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 64,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest.withAlpha(240)
                : theme.colorScheme.surfaceContainerLowest.withAlpha(240),
            borderRadius: BorderRadius.circular(32),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      // Artwork with play/pause overlay + rotation
                      GestureDetector(
                        onTap: () => ref
                            .read(podcastPlayerProvider.notifier)
                            .togglePlayback(),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Rotating artwork
                              RotationTransition(
                                turns: _rotationController,
                                child: ClipOval(
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.withAlpha(50),
                                      border: Border.all(
                                        color: theme.colorScheme.primary
                                            .withAlpha(40),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: episode.imageUrl.isNotEmpty
                                          ? BenaiahNetworkImage(
                                              imageUrl: episode.imageUrl,
                                            )
                                          : Icon(
                                              Icons.podcasts_rounded,
                                              color: theme.colorScheme.primary,
                                              size: 20,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              // Play/Pause icon overlay
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withAlpha(200),
                                  shape: BoxShape.circle,
                                ),
                                child: playerState.isBuffering
                                    ? const Padding(
                                        padding: EdgeInsets.all(6),
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
                                        size: 16,
                                      ),
                              ),
                            ],
                          ),
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
                      // Close button to remove player
                      GestureDetector(
                        onTap: () => ref
                            .read(podcastPlayerProvider.notifier)
                            .reset(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withAlpha(100),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: theme.colorScheme.primary.withAlpha(200),
                            size: 18,
                          ),
                        ),
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
