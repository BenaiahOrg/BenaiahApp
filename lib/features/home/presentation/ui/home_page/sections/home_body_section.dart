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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => BenaiahStateView.error(
        error: error,
        onRetry: () => ref.invalidate(seriesListProvider),
      ),
    );
  }
}
