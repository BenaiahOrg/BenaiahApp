import 'package:benaiah_app/core/widgets/benaiah_network_image.dart';
import 'package:benaiah_app/features/podcast/presentation/providers/podcast_player_notifier.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PodcastPlayerSheet extends ConsumerStatefulWidget {
  const PodcastPlayerSheet({super.key});

  @override
  ConsumerState<PodcastPlayerSheet> createState() => _PodcastPlayerSheetState();
}

class _PodcastPlayerSheetState extends ConsumerState<PodcastPlayerSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  bool _showRemaining = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    // Run rotation if playing initially
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

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  void _cyclePlaybackSpeed(double currentSpeed) {
    final notifier = ref.read(podcastPlayerProvider.notifier);
    if (currentSpeed == 1.0) {
      notifier.setPlaybackSpeed(1.25);
    } else if (currentSpeed == 1.25) {
      notifier.setPlaybackSpeed(1.5);
    } else if (currentSpeed == 1.5) {
      notifier.setPlaybackSpeed(2.0);
    } else {
      notifier.setPlaybackSpeed(1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(podcastPlayerProvider);
    final episode = playerState.currentEpisode;

    if (episode == null) {
      return const SizedBox.shrink();
    }

    // Control animation based on playback state
    if (playerState.isPlaying) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Spinning Cover & Rings
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulse concentric ring on play
                if (playerState.isPlaying)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 1.0, end: 1.25),
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Container(
                        width: 160 * value,
                        height: 160 * value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withAlpha(
                            (15 * (1.25 - value) / 0.25).round().clamp(0, 255),
                          ),
                        ),
                      );
                    },
                  ),
                // Cover Artwork Container
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
                          color: theme.colorScheme.primary.withAlpha(40),
                          blurRadius: 16,
                          spreadRadius: 2,
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
                                )
                              : ColoredBox(
                                  color: theme.colorScheme.primary,
                                  child: const Icon(
                                    Icons.podcasts_rounded,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Center pin hole representing vinyl disc look
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Category and Episode Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Season {} • Episode {}'
                  .tr(args: [
                    episode.seasonNumber.toString(),
                    episode.episodeNumber.toString(),
                  ])
                  .toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
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
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Progress Seek Bar
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: theme.colorScheme.primary,
              inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
              thumbColor: theme.colorScheme.primary,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 16,
              ),
            ),
            child: Slider(
              value: playerState.progress,
              onChanged: (val) =>
                  ref.read(podcastPlayerProvider.notifier).seek(val),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(playerState.currentSeconds),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showRemaining = !_showRemaining;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    _showRemaining
                        ? '-${_formatDuration(episode.durationSeconds - playerState.currentSeconds)}'
                        : _formatDuration(episode.durationSeconds),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Media Controls & Speed Switcher
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Speed control button
              TextButton(
                onPressed: () => _cyclePlaybackSpeed(playerState.playbackSpeed),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                  ),
                ),
                child: Text(
                  '${playerState.playbackSpeed.toStringAsFixed(2).replaceAll('.00', '')}x',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              // Skip 10s back
              IconButton(
                icon: const Icon(Icons.replay_10_rounded, size: 36),
                color: theme.colorScheme.onSurface,
                onPressed: () =>
                    ref.read(podcastPlayerProvider.notifier).skip(-10),
              ),
              // Play/Pause circular button
              GestureDetector(
                onTap: () =>
                    ref.read(podcastPlayerProvider.notifier).togglePlayback(),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withAlpha(80),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    playerState.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: theme.colorScheme.onPrimary,
                    size: 36,
                  ),
                ),
              ),
              // Skip 10s forward
              IconButton(
                icon: const Icon(Icons.forward_10_rounded, size: 36),
                color: theme.colorScheme.onSurface,
                onPressed: () =>
                    ref.read(podcastPlayerProvider.notifier).skip(10),
              ),
              // Quick description popup or small icon indicator
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, size: 28),
                color: Colors.grey,
                onPressed: () {
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
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
