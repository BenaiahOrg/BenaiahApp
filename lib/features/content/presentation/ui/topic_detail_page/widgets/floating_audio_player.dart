part of '../topic_detail_page.dart';

class _AudioPlayerController {
  _AudioPlayerController({
    required this.title,
    required this.subtitle,
    required this.totalDurationSeconds,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final int totalDurationSeconds;
  final String imageUrl;

  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<double> sliderValue = ValueNotifier(0);
  final ValueNotifier<int> currentSeconds = ValueNotifier(0);

  Timer? _playbackTimer;

  void togglePlayback() {
    isPlaying.value = !isPlaying.value;
    if (isPlaying.value) {
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  void _startTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentSeconds.value < totalDurationSeconds) {
        currentSeconds.value++;
        sliderValue.value = currentSeconds.value / totalDurationSeconds;
      } else {
        resetPlayback();
      }
    });
  }

  void _stopTimer() {
    _playbackTimer?.cancel();
  }

  void resetPlayback() {
    isPlaying.value = false;
    currentSeconds.value = 0;
    sliderValue.value = 0;
    _stopTimer();
  }

  void seek(double value) {
    sliderValue.value = value;
    currentSeconds.value = (value * totalDurationSeconds).round();
  }

  void skipSeconds(int delta) {
    currentSeconds.value = (currentSeconds.value + delta).clamp(
      0,
      totalDurationSeconds,
    );
    sliderValue.value = currentSeconds.value / totalDurationSeconds;
  }

  void dispose() {
    _playbackTimer?.cancel();
    isPlaying.dispose();
    sliderValue.dispose();
    currentSeconds.dispose();
  }
}

class _FloatingAudioPlayer extends StatefulWidget {
  const _FloatingAudioPlayer({
    required this.title,
    required this.subtitle,
    required this.totalDurationSeconds,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final int totalDurationSeconds;
  final String imageUrl;

  @override
  State<_FloatingAudioPlayer> createState() => _FloatingAudioPlayerState();
}

class _FloatingAudioPlayerState extends State<_FloatingAudioPlayer> {
  late final _AudioPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _AudioPlayerController(
      title: widget.title,
      subtitle: widget.subtitle,
      totalDurationSeconds: widget.totalDurationSeconds,
      imageUrl: widget.imageUrl,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openDetailedPlayerSheet() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) =>
            _AudioDetailedPlayerSheet(controller: _controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          height: 62,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest.withAlpha(235)
                : theme.colorScheme.surfaceContainerLowest.withAlpha(235),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 80 : 30),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black12,
            ),
          ),
          child: GestureDetector(
            onTap: _openDetailedPlayerSheet,
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Play/Pause circular button
                        ValueListenableBuilder<bool>(
                          valueListenable: _controller.isPlaying,
                          builder: (context, isPlaying, child) {
                            return GestureDetector(
                              onTap: _controller.togglePlayback,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: theme.colorScheme.onPrimary,
                                  size: 24,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        // Text and title info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.title,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.subtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Small icon showing detail indicator
                        Icon(
                          Icons.open_in_full_rounded,
                          color: theme.colorScheme.primary.withAlpha(150),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                // Micro Progress Indicator at the bottom edge
                ValueListenableBuilder<double>(
                  valueListenable: _controller.sliderValue,
                  builder: (context, progress, child) {
                    return SizedBox(
                      height: 3,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AudioDetailedPlayerSheet extends StatefulWidget {
  const _AudioDetailedPlayerSheet({required this.controller});

  final _AudioPlayerController controller;

  @override
  State<_AudioDetailedPlayerSheet> createState() =>
      _AudioDetailedPlayerSheetState();
}

class _AudioDetailedPlayerSheetState extends State<_AudioDetailedPlayerSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    // Sync initial rotation state
    if (widget.controller.isPlaying.value) {
      unawaited(_rotationController.repeat());
    }

    widget.controller.isPlaying.addListener(_onPlayingStateChanged);
  }

  void _onPlayingStateChanged() {
    if (mounted) {
      if (widget.controller.isPlaying.value) {
        unawaited(_rotationController.repeat());
      } else {
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    widget.controller.isPlaying.removeListener(_onPlayingStateChanged);
    _rotationController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
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
          // Drag handle indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          // Spinning Vinyl & concentrics
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Concentric ring animation
                ValueListenableBuilder<bool>(
                  valueListenable: widget.controller.isPlaying,
                  builder: (context, isPlaying, child) {
                    if (!isPlaying) return const SizedBox.shrink();
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 1, end: 1.3),
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Container(
                          width: 170 * value,
                          height: 170 * value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary.withAlpha(
                              (20 * (2.0 - value)).round().clamp(0, 255),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                // Spinning vinyl disc artwork
                RotationTransition(
                  turns: _rotationController,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black87,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withAlpha(50),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(6), // vinyl margin
                        child: ClipOval(
                          child: widget.controller.imageUrl.isNotEmpty
                              ? BenaiahNetworkImage(
                                  imageUrl: widget.controller.imageUrl,
                                )
                              : ColoredBox(
                                  color: theme.colorScheme.primary,
                                  child: const Icon(
                                    Icons.music_note_rounded,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Core spindle hole
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
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
          const SizedBox(height: 32),
          // Titles
          Text(
            widget.controller.title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.controller.subtitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Progress Seek Bar
          ValueListenableBuilder<double>(
            valueListenable: widget.controller.sliderValue,
            builder: (context, progress, child) {
              return SliderTheme(
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
                  value: progress,
                  onChanged: widget.controller.seek,
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: widget.controller.currentSeconds,
                  builder: (context, seconds, child) {
                    return Text(
                      _formatDuration(seconds),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
                ValueListenableBuilder<int>(
                  valueListenable: widget.controller.currentSeconds,
                  builder: (context, seconds, child) {
                    final remaining =
                        widget.controller.totalDurationSeconds - seconds;
                    return Text(
                      _formatDuration(remaining),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Control buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10_rounded, size: 32),
                color: theme.colorScheme.onSurface,
                onPressed: () => widget.controller.skipSeconds(-15),
              ),
              const SizedBox(width: 24),
              ValueListenableBuilder<bool>(
                valueListenable: widget.controller.isPlaying,
                builder: (context, isPlaying, child) {
                  return GestureDetector(
                    onTap: widget.controller.togglePlayback,
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
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 36,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(Icons.forward_10_rounded, size: 32),
                color: theme.colorScheme.onSurface,
                onPressed: () => widget.controller.skipSeconds(15),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Narration voice by Benaiah'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
