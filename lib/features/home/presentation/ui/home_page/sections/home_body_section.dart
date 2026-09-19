part of '../home_page.dart';

class _HomeBodySection extends ConsumerWidget {
  const _HomeBodySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesListAsync = ref.watch(seriesListProvider);

    return seriesListAsync.when(
      data: (seriesList) {
        if (seriesList.isEmpty) {
          return BenaiahStateView.empty(
            icon: Icons.auto_stories_outlined,
            title: 'Nothing here yet'.tr(),
            message: 'New series will appear here as they are published.'.tr(),
            onRetry: () => ref.invalidate(seriesListProvider),
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            if (seriesList.isNotEmpty)
              SliverToBoxAdapter(
                child: _FeaturedCarousel(seriesList: seriesList),
              ),
            _HomeAllSeriesSection(seriesList: seriesList),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
      loading: () => const _HomeSkeleton(),
      error: (error, stack) => BenaiahStateView.error(
        error: error,
        onRetry: () => ref.invalidate(seriesListProvider),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ShimmerBox(height: 320, borderRadius: 16),
          const SizedBox(height: 24),
          const ShimmerBox(width: 110, height: 20, borderRadius: 4),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 24,
            childAspectRatio: 0.75,
            children: List.generate(
              4,
              (_) => const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ShimmerBox(borderRadius: 16),
                  ),
                  SizedBox(height: 12),
                  ShimmerBox(height: 16, borderRadius: 4),
                  SizedBox(height: 4),
                  ShimmerBox(width: 60, height: 12, borderRadius: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
