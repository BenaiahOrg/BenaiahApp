import 'package:benaiah_app/core/error/result.dart';
import 'package:benaiah_app/features/podcast/domain/entities/podcast_episode.dart';

abstract class PodcastRepository {
  Future<Result<List<PodcastEpisode>>> getEpisodes();
  Future<Result<PodcastEpisode>> getEpisodeById(String id);
}
