import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:benaiah_app/core/di/injection.dart';
import 'package:benaiah_app/core/error/result.dart';
import 'package:benaiah_app/features/podcast/domain/entities/podcast_episode.dart';
import 'package:benaiah_app/features/podcast/domain/repositories/podcast_repository.dart';

part 'podcast_detail_notifier.g.dart';

@riverpod
class PodcastDetailNotifier extends _$PodcastDetailNotifier {
  PodcastRepository get _repository => container<PodcastRepository>();

  @override
  FutureOr<PodcastEpisode> build(String episodeId) async {
    return _fetchEpisode(episodeId);
  }

  Future<PodcastEpisode> _fetchEpisode(String id) async {
    final result = await _repository.getEpisodeById(id);
    return switch (result) {
      Success(data: final episode) => episode,
      Failure(:final error) => throw error,
    };
  }
}
