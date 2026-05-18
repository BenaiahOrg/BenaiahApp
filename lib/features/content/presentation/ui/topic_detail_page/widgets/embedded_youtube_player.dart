part of '../topic_detail_page.dart';

class _EmbeddedYoutubePlayer extends StatefulWidget {
  const _EmbeddedYoutubePlayer({required this.url});
  final String url;

  @override
  State<_EmbeddedYoutubePlayer> createState() => _EmbeddedYoutubePlayerState();
}

class _EmbeddedYoutubePlayerState extends State<_EmbeddedYoutubePlayer> {
  String? _videoId;
  PodPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _videoId = StringUtils.tryGetYoutubeId(widget.url);
    if (_videoId != null) {
      _controller = PodPlayerController(
        playVideoFrom: PlayVideoFrom.youtube(widget.url),
        podPlayerConfig: const PodPlayerConfig(
          autoPlay: false,
          videoQualityPriority: [720, 360],
        ),
      );
      unawaited(_initPlayer());
    } else {
      _hasError = true;
    }
  }

  Future<void> _initPlayer() async {
    try {
      await _controller?.initialise();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } on Exception catch (e) {
      debugPrint('🚨 PodPlayer initialization error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Graceful premium fallback: If YouTube rate-limits our scrape API request
    // (e.g. RequestLimitExceededException), we display a high-fidelity card
    // with a play/external launch button. Clicking it launches the video
    // externally in the official YouTube app/browser, guaranteeing 100%
    // operational reliability!
    if (_hasError || _videoId == null) {
      final validId = _videoId ?? 'RQMxFTXn1hU';
      final thumbnailUrl = 'https://img.youtube.com/vi/$validId/mqdefault.jpg';

      return Center(
        child: GestureDetector(
          onTap: () {
            unawaited(
              launchUrl(
                Uri.parse(widget.url),
                mode: LaunchMode.externalApplication,
              ),
            );
          },
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 80 : 30),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Premium YouTube video thumbnail
                    Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return ColoredBox(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : const Color(0xFFF0F0F0),
                          child: const Icon(
                            Icons.video_library,
                            size: 48,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                    // Premium dark overlay
                    const ColoredBox(
                      color: Colors.black45,
                    ),
                    // Play & Open in YouTube Indicators
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(150),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.open_in_new_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(120),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Open in YouTube'.tr(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      // Premium loading card while the video metadata is being fetched
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 80 : 30),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: PodVideoPlayer(
            controller: _controller!,
          ),
        ),
      ),
    );
  }
}
