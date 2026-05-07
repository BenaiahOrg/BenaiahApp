part of '../topic_detail_page.dart';

class _GraphicItem extends StatelessWidget {
  const _GraphicItem({required this.imageUrl, required this.topicTitle});
  final String imageUrl;
  final String topicTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              unawaited(
                showDialog<void>(
                  context: context,
                  builder: (context) => Dialog.fullscreen(
                    backgroundColor: Colors.black,
                    child: Stack(
                      children: [
                        Center(
                          child: InteractiveViewer(
                            clipBehavior: Clip.none,
                            child: BenaiahNetworkImage(
                              imageUrl: imageUrl,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  BenaiahNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            try {
                              await ImageUtils.downloadAndSaveImage(imageUrl);
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
                                      'Error downloading image'.tr(),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.download, color: Colors.white),
                          tooltip: 'Download'.tr(),
                        ),
                        IconButton(
                          onPressed: () => ImageUtils.shareImage(
                            imageUrl,
                            topicTitle,
                          ),
                          icon: const Icon(Icons.share, color: Colors.white),
                          tooltip: 'Share'.tr(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
