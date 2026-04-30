import 'package:benaiah_app/core/error/result.dart';
import 'package:benaiah_app/features/content/domain/entities/series.dart';
import 'package:benaiah_app/features/content/domain/entities/topic.dart';

abstract class ContentRepository {
  Future<Result<List<Series>>> getSeriesList();
  Future<Result<Series>> getSeriesById(String id);
  Future<Result<Topic>> getTopicById(String id);
}
