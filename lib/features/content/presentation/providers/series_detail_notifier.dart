import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:benaiah_app/core/di/injection.dart';
import 'package:benaiah_app/core/error/result.dart';
import 'package:benaiah_app/features/content/domain/entities/series.dart';
import 'package:benaiah_app/features/content/domain/repositories/content_repository.dart';

part 'series_detail_notifier.g.dart';

@riverpod
class SeriesDetailNotifier extends _$SeriesDetailNotifier {
  ContentRepository get _repository => container<ContentRepository>();

  @override
  FutureOr<Series> build(String seriesId) async {
    return _fetchSeries(seriesId);
  }

  Future<Series> _fetchSeries(String id) async {
    final result = await _repository.getSeriesById(id);
    return switch (result) {
      Success(data: final series) => series,
      Failure(:final error) => throw error,
    };
  }
}
