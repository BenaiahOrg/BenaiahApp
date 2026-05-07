part of '../home_page.dart';

class _HomeAllSeriesSection extends StatelessWidget {
  const _HomeAllSeriesSection({required this.seriesList});

  final List<Series> seriesList;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Text(
                  'All Series'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Series List coming soon!'.tr()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text('View All'.tr()),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final series = seriesList[index];
                return _SeriesCard(series: series);
              },
              childCount: seriesList.length,
            ),
          ),
        ),
      ],
    );
  }
}
