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
        data: (episodes) {
          // Apply category filters
          final filteredEpisodes = episodes.where((ep) {
            return _selectedCategory == 'All' ||
                ep.category == _selectedCategory;
          }).toList();

          // Separate featured episode (latest first)
          PodcastEpisode? featuredEpisode;
          var listEpisodes = filteredEpisodes;
          if (_selectedCategory == 'All' && filteredEpisodes.isNotEmpty) {
            featuredEpisode = filteredEpisodes.first;
            listEpisodes = filteredEpisodes.skip(1).toList();
          }

          return CustomScrollView(
            slivers: [
              // Horizontal Category Chips
              _PodcastCategoryChips(
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),

              if (filteredEpisodes.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Colors.grey.withAlpha(100),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found.'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Featured Episode Banner
              if (featuredEpisode != null)
                _FeaturedEpisodeBanner(
                  episode: featuredEpisode,
                  onTap: () => _navigateToDetail(featuredEpisode!),
                ),

              // Regular Episodes List
              if (listEpisodes.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      _selectedCategory == 'All'
                          ? 'All Episodes'.tr()
                          : 'Episodes'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

              if (listEpisodes.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final ep = listEpisodes[index];
                        return _PodcastEpisodeListTile(
                          episode: ep,
                          onTap: () => _navigateToDetail(ep),
                        );
                      },
                      childCount: listEpisodes.length,
                    ),
                  ),
                ),

              // Safe spacing for the global mini floating player
              const SliverToBoxAdapter(
                child: SizedBox(height: 84),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error loading content.'.tr()),
        ),
      ),
    );
  }
}
