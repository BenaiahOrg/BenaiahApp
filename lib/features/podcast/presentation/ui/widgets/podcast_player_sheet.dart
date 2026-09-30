import 'dart:async';

import 'package:benaiah_app/core/widgets/benaiah_network_image.dart';
import 'package:benaiah_app/features/podcast/presentation/providers/podcast_player_notifier.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Opens the full player as a modal bottom sheet (drag handle and colors come
/// from the theme's bottom sheet style).
Future<void> showPodcastPlayerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const PodcastPlayerSheet(),
  );
}

class PodcastPlayerSheet extends ConsumerStatefulWidget {
  const PodcastPlayerSheet({super.key});

  @override
  ConsumerState<PodcastPlayerSheet> createState() => _PodcastPlayerSheetState();
}

class _PodcastPlayerSheetState extends ConsumerState<PodcastPlayerSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );
  bool _showRemaining = false;

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  void _cyclePlaybackSpeed(double currentSpeed) {
    final notifier = ref.read(podcastPlayerProvider.notifier);
    if (currentSpeed == 1.0) {
      unawaited(notifier.setPlaybackSpeed(1.25));
    } else if (currentSpeed == 1.25) {
      unawaited(notifier.setPlaybackSpeed(1.5));
    } else if (currentSpeed == 1.5) {
      unawaited(notifier.setPlaybackSpeed(2));
    } else {
      unawaited(notifier.setPlaybackSpeed(1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(podcastPlayerProvider);
    final episode = playerState.currentEpisode;

    if (episode == null) {
      return const SizedBox.shrink();
    }

    // The cover turns like a record while audio plays, and holds still when
    // the system asks for reduced motion.
    final spin =
        playerState.isPlaying && !MediaQuery.disableAnimationsOf(context);
    if (spin && !_rotationController.isAnimating) {
      _rotationController.repeat();
    } else if (!spin && _rotationController.isAnimating) {
      _rotationController.stop();
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onSurfaceVariant;
    final notifier = ref.read(podcastPlayerProvider.notifier);
    // Tabular figures keep the timecodes from jittering as digits change.
    final timeStyle = theme.textTheme.bodySmall?.copyWith(
      color: muted,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final playLabel = (playerState.isPlaying ? 'Pause' : 'Play').tr();
    final remainingSeconds =
        episode.durationSeconds - playerState.currentSeconds;
    final speed = playerState.playbackSpeed.toStringAsFixed(2);
    final speedLabel = '${speed.replaceAll('.00', '')}x';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  RotationTransition(
                    turns: _rotationController,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black87,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(60),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: ClipOval(
                            child: episode.imageUrl.isNotEmpty
                                ? BenaiahNetworkImage(
                                    imageUrl: episode.imageUrl,
                                    width: 148,
                                    height: 148,
                                  )
                                : ColoredBox(
                                    color: scheme.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.podcasts_rounded,
                                      size: 64,
                                      color: muted,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Spindle hole, so the spinning cover reads as a record.
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.outline, width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: scheme.outline,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              episode.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              episode.hosts.map((h) => h.name).join(', '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: muted,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              'Season {} • Episode {}'.tr(
                args: [
                  episode.seasonNumber.toString(),
                  episode.episodeNumber.toString(),
                ],
              ),
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                activeTrackColor: scheme.primary,
                inactiveTrackColor: scheme.outlineVariant,
                thumbColor: scheme.primary,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 8,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 16,
                ),
              ),
              child: Slider(
                value: playerState.progress,
                // Screen readers hear the position ("12:04"), not a percent.
                semanticFormatterCallback: (value) => _formatDuration(
                  (value * episode.durationSeconds).round(),
                ),
                onChanged: (val) => unawaited(notifier.seek(val)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      _formatDuration(playerState.currentSeconds),
                      style: timeStyle,
                    ),
                  ),
                  // Tapping the total flips it to the time remaining.
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        _showRemaining = !_showRemaining;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        _showRemaining
                            ? '-${_formatDuration(remainingSeconds)}'
                            : _formatDuration(episode.durationSeconds),
                        style: timeStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Tooltip(
                  message: 'Playback speed'.tr(),
                  child: TextButton(
                    onPressed: () =>
                        _cyclePlaybackSpeed(playerState.playbackSpeed),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      shape: StadiumBorder(
                        side: BorderSide(color: scheme.outlineVariant),
                      ),
                    ),
                    child: Text(
                      speedLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.replay_10_rounded),
                  iconSize: 36,
                  color: scheme.onSurface,
                  tooltip: 'Back 10 seconds'.tr(),
                  onPressed: () => unawaited(notifier.skip(-10)),
                ),
                IconButton.filled(
                  onPressed: () => unawaited(notifier.togglePlayback()),
                  tooltip: playLabel,
                  iconSize: 36,
                  style: IconButton.styleFrom(
                    fixedSize: const Size.square(64),
                  ),
                  icon: playerState.isBuffering
                      ? SizedBox.square(
                          dimension: 28,
                          child: CircularProgressIndicator(
                            color: scheme.onPrimary,
                            strokeWidth: 3,
                          ),
                        )
                      : Icon(
                          playerState.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10_rounded),
                  iconSize: 36,
                  color: scheme.onSurface,
                  tooltip: 'Forward 10 seconds'.tr(),
                  onPressed: () => unawaited(notifier.skip(10)),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline_rounded),
                  iconSize: 28,
                  color: muted,
                  tooltip: 'Episode Description'.tr(),
                  onPressed: () {
                    unawaited(
                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(episode.title),
                          content: Scrollbar(
                            child: SingleChildScrollView(
                              child: Text(
                                episode.description,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Close'.tr()),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
