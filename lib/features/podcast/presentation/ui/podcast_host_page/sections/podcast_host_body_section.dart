part of '../podcast_host_page.dart';

class _PodcastHostBodySection extends ConsumerWidget {
  const _PodcastHostBodySection({required this.hostId});

  final String hostId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodesAsync = ref.watch(podcastListProvider);

    return episodesAsync.when(
      data: (episodes) {
        final hostedEpisodes = episodes
            .where((ep) => ep.hosts.any((h) => h.id == hostId))
            .toList();

        final host = hostedEpisodes
            .expand((ep) => ep.hosts)
            .firstWhere((h) => h.id == hostId, orElse: _unknownHost);

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
            ),
            SliverToBoxAdapter(
              child: _PodcastHostHeader(host: host),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Episodes'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            if (hostedEpisodes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: BenaiahStateView.empty(
                  icon: Icons.mic_off_outlined,
                  title: 'No episodes found for this host'.tr(),
                  compact: true,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final episode = hostedEpisodes[index];
                      return PodcastEpisodeTile(
                        episode: episode,
                        onTap: () {
                          unawaited(
                            context.push(
                              RouteNames.podcastDetail.replaceAll(
                                ':episodeId',
                                episode.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: hostedEpisodes.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const SkeletonList(imageSize: 100),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: BenaiahStateView.error(
          error: error,
          onRetry: () => ref.invalidate(podcastListProvider),
        ),
      ),
    );
  }

  static PodcastHost _unknownHost() {
    return const PodcastHost(id: '', name: '', bio: '', imageUrl: '');
  }
}

/// Square photo above the name, mirroring the app's author-profile header.
class _PodcastHostHeader extends StatelessWidget {
  const _PodcastHostHeader({required this.host});

  final PodcastHost host;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BenaiahNetworkImage(
              imageUrl: host.imageUrl,
              width: 120,
              height: 120,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            host.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (host.bio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              host.bio,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
