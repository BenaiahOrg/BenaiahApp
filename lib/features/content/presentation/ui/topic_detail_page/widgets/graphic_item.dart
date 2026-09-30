part of '../topic_detail_page.dart';

class _GraphicItem extends StatelessWidget {
  const _GraphicItem({
    required this.imageUrl,
    required this.topicTitle,
    required this.allImages,
    required this.initialIndex,
  });

  final String imageUrl;
  final String topicTitle;
  final List<String> allImages;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          Semantics(
            button: true,
            label: '$topicTitle, ${_position(initialIndex, allImages.length)}',
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder<void>(
                    barrierColor: Colors.black,
                    pageBuilder: (context, _, _) => _FullscreenGalleryDialog(
                      allImages: allImages,
                      initialIndex: initialIndex,
                      topicTitle: topicTitle,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BenaiahNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  // The masonry tile takes its height from the decoded image,
                  // so the default placeholder has no height to fill and the
                  // grid stays blank until pictures pop in. Hold a square —
                  // most graphics are square — so the tab shows a skeleton
                  // while they load.
                  placeholder: const AspectRatio(
                    aspectRatio: 1,
                    child: Shimmer(child: ShimmerBox(borderRadius: 16)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "2 of 18", for the gallery counter and each thumbnail's spoken label.
String _position(int index, int count) =>
    '{} of {}'.tr(args: ['${index + 1}', '$count']);

class _FullscreenGalleryDialog extends StatefulWidget {
  const _FullscreenGalleryDialog({
    required this.allImages,
    required this.initialIndex,
    required this.topicTitle,
  });

  final List<String> allImages;
  final int initialIndex;
  final String topicTitle;

  @override
  State<_FullscreenGalleryDialog> createState() =>
      _FullscreenGalleryDialogState();
}

class _FullscreenGalleryDialogState extends State<_FullscreenGalleryDialog> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUrl = widget.allImages[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.allImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                clipBehavior: Clip.none,
                minScale: 0.5,
                maxScale: 4,
                child: Center(
                  child: BenaiahNetworkImage(
                    imageUrl: widget.allImages[index],
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close'.tr(),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.topicTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _position(_currentIndex, widget.allImages.length),
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: () async {
                        try {
                          await ImageUtils.downloadAndSaveImage(currentUrl);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Image saved to gallery'.tr(),
                                ),
                              ),
                            );
                          }
                        } on Exception catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Could not save the image. Try again.'.tr(),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      tooltip: 'Download'.tr(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: () => ImageUtils.shareImage(
                        currentUrl,
                        widget.topicTitle,
                      ),
                      tooltip: 'Share'.tr(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
