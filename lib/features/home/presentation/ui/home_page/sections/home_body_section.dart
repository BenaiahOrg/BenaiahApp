part of '../home_page.dart';

class _HomeBodySection extends ConsumerWidget {
  const _HomeBodySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesListAsync = ref.watch(seriesListProvider);

    return seriesListAsync.when(
      data: (seriesList) {
        if (seriesList.isEmpty) return const SizedBox.shrink();

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const _HomeTopSection(),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
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
      error: (error, stack) => Center(
        child: Text(
          error is AppError
              ? error.userMessage
              : 'Error: {}'.tr(args: [error.toString()]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
