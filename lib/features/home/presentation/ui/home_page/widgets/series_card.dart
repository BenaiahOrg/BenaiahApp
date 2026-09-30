part of '../home_page.dart';

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({required this.series});

  final Series series;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        unawaited(
          context.pushNamed(
            RouteNames.seriesDetail,
            pathParameters: {'seriesId': series.id},
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: BenaiahNetworkImage(
                imageUrl: series.imageUrl,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            series.localizedTitle(context.locale.languageCode),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '{} Topics'.tr(args: [series.topics.length.toString()]),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
