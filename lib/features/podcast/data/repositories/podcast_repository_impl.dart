import 'package:benaiah_app/core/error/app_error.dart';
import 'package:benaiah_app/core/error/result.dart';
import 'package:benaiah_app/features/podcast/data/data_sources/podcast_remote_data_source.dart';
import 'package:benaiah_app/features/podcast/domain/entities/podcast_episode.dart';
import 'package:benaiah_app/features/podcast/domain/repositories/podcast_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PodcastRepository)
class PodcastRepositoryImpl implements PodcastRepository {
  PodcastRepositoryImpl(this._remoteDataSource);

  final PodcastRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<PodcastEpisode>>> getEpisodes() async {
    return _remoteDataSource.getEpisodes();
  }

  @override
  Future<Result<PodcastEpisode>> getEpisodeById(String id) async {
    final result = await _remoteDataSource.getEpisodes();
    return switch (result) {
      Success(data: final list) => switch (list
          .where((ep) => ep.id == id)
          .firstOrNull) {
        final episode? => Success(episode),
        null => const Failure(NotFoundError()),
      },
      Failure(error: final e) => Failure(e),
    };
  }
}
