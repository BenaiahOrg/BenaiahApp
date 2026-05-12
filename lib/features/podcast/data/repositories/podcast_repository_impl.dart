import 'package:benaiah_app/core/error/result.dart';
import 'package:benaiah_app/features/podcast/domain/entities/podcast_episode.dart';
import 'package:benaiah_app/features/podcast/domain/repositories/podcast_repository.dart';
import 'package:injectable/injectable.dart';

import 'package:benaiah_app/features/podcast/data/data_sources/podcast_remote_data_source.dart';
import 'package:benaiah_app/features/podcast/data/data_sources/podcast_local_data_source.dart';

@LazySingleton(as: PodcastRepository)
class PodcastRepositoryImpl implements PodcastRepository {
  PodcastRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final PodcastRemoteDataSource _remoteDataSource;
  final PodcastLocalDataSource _localDataSource;

  @override
  Future<Result<List<PodcastEpisode>>> getEpisodes() async {
    return _remoteDataSource.getEpisodes();
  }

  @override
  Future<Result<PodcastEpisode>> getEpisodeById(String id) async {
    final result = await _remoteDataSource.getEpisodes();
    return switch (result) {
      Success(data: final list) => Success(
        list.firstWhere((ep) => ep.id == id),
      ),
      Failure(error: final e) => Failure(e),
    };
  }
}
