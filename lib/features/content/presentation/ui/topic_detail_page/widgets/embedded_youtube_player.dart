part of '../topic_detail_page.dart';

class _EmbeddedYoutubePlayer extends StatefulWidget {
  const _EmbeddedYoutubePlayer({required this.videoId});

  final String videoId;

  @override
  State<_EmbeddedYoutubePlayer> createState() => _EmbeddedYoutubePlayerState();
}

class _EmbeddedYoutubePlayerState extends State<_EmbeddedYoutubePlayer> {
  late final YoutubePlayerController _controller =
      YoutubePlayerController.fromVideoId(
        videoId: widget.videoId,
        params: const YoutubePlayerParams(showFullscreenButton: true),
      );

  @override
  void dispose() {
    unawaited(_controller.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          child: YoutubePlayer(controller: _controller),
        ),
      ),
    );
  }
}
