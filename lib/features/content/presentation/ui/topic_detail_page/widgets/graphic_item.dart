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
                  builder: (dialogContext) => Dialog.fullscreen(
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
                          top: MediaQuery.of(dialogContext).padding.top + 8,
                          left: 16,
                          right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.download,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    onPressed: () async {
                                      try {
                                        await ImageUtils.downloadAndSaveImage(
                                          imageUrl,
                                        );
                                        if (dialogContext.mounted) {
                                          ScaffoldMessenger.of(dialogContext)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Image saved to gallery'.tr(),
                                              ),
                                            ),
                                          );
                                        }
                                      } on Exception catch (_) {
                                        if (dialogContext.mounted) {
                                          ScaffoldMessenger.of(dialogContext)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error downloading image'.tr(),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    tooltip: 'Download'.tr(),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.share,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    onPressed: () => ImageUtils.shareImage(
                                      imageUrl,
                                      topicTitle,
                                    ),
                                    tooltip: 'Share'.tr(),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                              ),
                            ],
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
              child: BenaiahNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
