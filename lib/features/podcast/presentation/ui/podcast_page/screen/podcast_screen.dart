part of '../podcast_page.dart';

class _PodcastScreen extends ConsumerStatefulWidget {
  const _PodcastScreen();

  @override
  ConsumerState<_PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends ConsumerState<_PodcastScreen> {
  String _selectedCategory = 'All';

  void _navigateToDetail(PodcastEpisode episode) {
    unawaited(
      context.push(
        RouteNames.podcastDetail.replaceAll(':episodeId', episode.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final episodesAsync = ref.watch(podcastListProvider);

    return Scaffold(
      body: episodesAsync.when(
        data: (episodes) => LayoutBuilder(
          builder: (context, constraints) {
            final insets = AppLayout.readingInsetsForWidth(
              constraints.maxWidth,
              min: 16,
            );

            final categories = {
              for (final ep in episodes)
                if (ep.category.isNotEmpty) ep.category,
            }.toList()..sort();

            final filteredEpisodes = episodes.where((ep) {
              return _selectedCategory == 'All' ||
                  ep.category == _selectedCategory;
            }).toList();

            // Episodes arrive newest first; under "All" the newest one is
            // featured in the banner instead of repeated in the list.
            PodcastEpisode? featuredEpisode;
            var listEpisodes = filteredEpisodes;
            if (_selectedCategory == 'All' && filteredEpisodes.isNotEmpty) {
              featuredEpisode = filteredEpisodes.first;
              listEpisodes = filteredEpisodes.skip(1).toList();
            }

            return CustomScrollView(
              slivers: [
                // With one category the chips would only repeat "All", so
                // show them once there is a choice.
                if (categories.length > 1)
                  _PodcastCategoryChips(
                    categories: categories,
                    selectedCategory: _selectedCategory,
                    insets: insets,
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),

                if (filteredEpisodes.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: episodes.isEmpty
                        ? BenaiahStateView.empty(
                            icon: Icons.podcasts_outlined,
                            title: 'No episodes yet'.tr(),
                            message: 'New episodes will appear here.'.tr(),
                            onRetry: () => ref.invalidate(podcastListProvider),
                          )
                        : BenaiahStateView.empty(
                            icon: Icons.search_off_rounded,
                            title: 'No results found.'.tr(),
                          ),
                  ),

                if (featuredEpisode != null)
                  _FeaturedEpisodeBanner(
                    episode: featuredEpisode,
                    insets: insets,
                    onTap: () => _navigateToDetail(featuredEpisode!),
                  ),

                if (listEpisodes.isNotEmpty)
                  SliverPadding(
                    // Without the banner above, the heading needs its own
                    // space below the chips.
                    padding: insets.copyWith(
                      top: featuredEpisode == null ? 24 : 0,
                      bottom: 16,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        _selectedCategory == 'All'
                            ? 'All Episodes'.tr()
                            : 'Episodes'.tr(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                if (listEpisodes.isNotEmpty)
                  SliverPadding(
                    padding: insets,
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final ep = listEpisodes[index];
                          return PodcastEpisodeTile(
                            episode: ep,
                            onTap: () => _navigateToDetail(ep),
                          );
                        },
                        childCount: listEpisodes.length,
                      ),
                    ),
                  ),

                // Keeps the last tile clear of the floating mini player.
                const SliverToBoxAdapter(
                  child: SizedBox(height: 84),
                ),
              ],
            );
          },
        ),
        loading: () => const _PodcastSkeleton(),
        error: (error, stack) => BenaiahStateView.error(
          error: error,
          onRetry: () => ref.invalidate(podcastListProvider),
        ),
      ),
    );
  }
}

class _PodcastSkeleton extends StatelessWidget {
  const _PodcastSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 180, borderRadius: 0),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 220, height: 20, borderRadius: 4),
                      SizedBox(height: 8),
                      ShimmerBox(height: 12, borderRadius: 4),
                      SizedBox(height: 6),
                      ShimmerBox(width: 160, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const ShimmerBox(width: 120, height: 20, borderRadius: 4),
          const SizedBox(height: 16),
          ...List.generate(
            4,
            (_) => const SkeletonPodcastTile(),
          ),
        ],
      ),
    );
  }
}
