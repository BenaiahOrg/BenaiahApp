part of '../series_detail_page.dart';

class _SeriesDetailScreen extends ConsumerWidget {
  const _SeriesDetailScreen({required this.seriesId});

  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: _SeriesDetailBodySection(seriesId: seriesId),
    );
  }
}
