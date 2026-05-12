part of '../topic_detail_page.dart';

class FloatingAudioPlayer extends StatefulWidget {
  const FloatingAudioPlayer({
    required this.title,
    required this.subtitle,
    required this.totalDurationSeconds,
    required this.imageUrl,
    super.key,
  });

  final String title;
  final String subtitle;
  final int totalDurationSeconds;
  final String imageUrl;

  @override
  State<FloatingAudioPlayer> createState() => _FloatingAudioPlayerState();
}

class _FloatingAudioPlayerState extends State<FloatingAudioPlayer> {
  late final AudioPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AudioPlayerController(
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
        builder: (context) => AudioDetailedPlayerSheet(controller: _controller),
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
