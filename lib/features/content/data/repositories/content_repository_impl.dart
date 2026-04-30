import 'package:injectable/injectable.dart';
import 'package:benaiah_app/core/error/result.dart';
import 'package:benaiah_app/features/content/domain/entities/series.dart';
import 'package:benaiah_app/features/content/domain/entities/topic.dart';
import 'package:benaiah_app/features/content/domain/repositories/content_repository.dart';
import 'package:benaiah_app/features/content/data/data_sources/content_remote_data_source.dart';
import 'package:benaiah_app/features/content/data/data_sources/content_local_data_source.dart';

@LazySingleton(as: ContentRepository)
class ContentRepositoryImpl implements ContentRepository {
  ContentRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final ContentRemoteDataSource _remoteDataSource;
  final ContentLocalDataSource _localDataSource;

  @override
  Future<Result<List<Series>>> getSeriesList() async {
    // For now, delegate to remote data source or return mock
    return _remoteDataSource.getSeriesList();
  }

  @override
  Future<Result<Series>> getSeriesById(String id) async {
    return _remoteDataSource.getSeriesById(id);
  }

  @override
  Future<Result<Topic>> getTopicById(String id) async {
    return _remoteDataSource.getTopicById(id);
  }
}
