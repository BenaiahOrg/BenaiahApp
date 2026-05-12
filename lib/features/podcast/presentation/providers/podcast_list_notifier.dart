import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:benaiah_app/core/di/injection.dart';
import 'package:benaiah_app/core/error/result.dart';
import 'package:benaiah_app/features/podcast/domain/entities/podcast_episode.dart';
import 'package:benaiah_app/features/podcast/domain/repositories/podcast_repository.dart';

part 'podcast_list_notifier.g.dart';

@riverpod
class PodcastListNotifier extends _$PodcastListNotifier {
  PodcastRepository get _repository => container<PodcastRepository>();

  @override
  FutureOr<List<PodcastEpisode>> build() async {
    return _fetchEpisodes();
  }

  Future<List<PodcastEpisode>> _fetchEpisodes() async {
    final result = await _repository.getEpisodes();
    return switch (result) {
      Success(data: final episodes) => episodes,
      Failure(:final error) => throw error,
    };
  }
}
