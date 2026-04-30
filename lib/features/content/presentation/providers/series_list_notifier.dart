import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:benaiah_app/core/di/injection.dart';
import 'package:benaiah_app/core/error/result.dart';
import 'package:benaiah_app/features/content/domain/entities/series.dart';
import 'package:benaiah_app/features/content/domain/repositories/content_repository.dart';

part 'series_list_notifier.g.dart';

@riverpod
class SeriesListNotifier extends _$SeriesListNotifier {
  ContentRepository get _repository => container<ContentRepository>();

  @override
  FutureOr<List<Series>> build() async {
    return _fetchSeries();
  }

  Future<List<Series>> _fetchSeries() async {
    final result = await _repository.getSeriesList();
    return switch (result) {
      Success(data: final series) => series,
      Failure(:final error) => throw error,
    };
  }
}
