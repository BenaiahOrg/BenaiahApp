part of '../podcast_detail_page.dart';

class _PodcastDetailHeaderSection extends StatelessWidget {
  const _PodcastDetailHeaderSection({required this.episode});

  final PodcastEpisode episode;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      leading: const ImageHeaderBackButton(),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final collapsedHeight =
              kToolbarHeight + MediaQuery.paddingOf(context).top;
          return ImageHeaderStatusBar(
            overArtwork: constraints.maxHeight > collapsedHeight + 24,
            child: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  BenaiahNetworkImage(
                    imageUrl: episode.imageUrl,
                  ),
                  const ImageHeaderScrim(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
