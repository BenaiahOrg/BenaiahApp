import 'dart:async';
import 'dart:developer' as developer;
import 'package:benaiah_app/features/podcast/domain/entities/podcast_episode.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_player_notifier.g.dart';

class PodcastPlayerState {
  const PodcastPlayerState({
    this.currentEpisode,
    this.isPlaying = false,
    this.currentSeconds = 0,
    this.playbackSpeed = 1.0,
  });

  final PodcastEpisode? currentEpisode;
  final bool isPlaying;
  final int currentSeconds;
  final double playbackSpeed;

  int get durationSeconds => currentEpisode?.durationSeconds ?? 0;
  double get progress =>
      durationSeconds > 0 ? currentSeconds / durationSeconds : 0.0;

  PodcastPlayerState copyWith({
    PodcastEpisode? currentEpisode,
    bool? isPlaying,
    int? currentSeconds,
    double? playbackSpeed,
    bool clearEpisode = false,
  }) {
    return PodcastPlayerState(
      currentEpisode:
          clearEpisode ? null : (currentEpisode ?? this.currentEpisode),
      isPlaying: isPlaying ?? this.isPlaying,
      currentSeconds: currentSeconds ?? this.currentSeconds,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }
}

@riverpod
class PodcastPlayerNotifier extends _$PodcastPlayerNotifier {
  late final AudioPlayer _audioPlayer;
  StreamSubscription<Duration?>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  PodcastPlayerState build() {
    _audioPlayer = AudioPlayer();

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (state.currentEpisode != null) {
        state = state.copyWith(currentSeconds: position.inSeconds);
      }
    });

    _playerStateSubscription =
        _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.completed) {
        unawaited(_audioPlayer.pause());
        unawaited(_audioPlayer.seek(Duration.zero));
        state = state.copyWith(isPlaying: false, currentSeconds: 0);
      } else {
        state = state.copyWith(isPlaying: isPlaying);
      }
    });

    ref.onDispose(() {
      unawaited(_positionSubscription?.cancel());
      unawaited(_playerStateSubscription?.cancel());
      unawaited(_audioPlayer.dispose());
    });

    return const PodcastPlayerState();
  }

  Future<void> play(PodcastEpisode episode) async {
    if (state.currentEpisode?.id == episode.id) {
      if (!state.isPlaying) {
        unawaited(_audioPlayer.play());
      }
      return;
    }

    state = PodcastPlayerState(
      currentEpisode: episode,
      playbackSpeed: state.playbackSpeed,
    );

    try {
      await _audioPlayer.setUrl(episode.audioUrl);
      await _audioPlayer.setSpeed(state.playbackSpeed);
      unawaited(_audioPlayer.play());
    } on Exception catch (e) {
      developer.log(
        'Error loading audio URL ${episode.audioUrl}',
        error: e,
        name: 'PodcastPlayerNotifier',
      );
    }
  }

  Future<void> togglePlayback() async {
    if (state.currentEpisode == null) return;

    if (state.isPlaying) {
      await _audioPlayer.pause();
    } else {
      unawaited(_audioPlayer.play());
    }
  }

  Future<void> seek(double progressFraction) async {
    if (state.currentEpisode == null) return;
    final targetSeconds = (progressFraction * state.durationSeconds)
        .round()
        .clamp(0, state.durationSeconds);
    await _audioPlayer.seek(Duration(seconds: targetSeconds));
  }

  Future<void> skip(int deltaSeconds) async {
    if (state.currentEpisode == null) return;
    final targetSeconds = (state.currentSeconds + deltaSeconds)
        .clamp(0, state.durationSeconds);
    await _audioPlayer.seek(Duration(seconds: targetSeconds));
  }

  Future<void> setPlaybackSpeed(double speed) async {
    state = state.copyWith(playbackSpeed: speed);
    await _audioPlayer.setSpeed(speed);
  }

  Future<void> reset() async {
    await _audioPlayer.stop();
    state = const PodcastPlayerState();
  }
}
