import 'dart:async';
import 'package:benaiah_app/features/podcast/domain/entities/podcast_episode.dart';
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
  double get progress => durationSeconds > 0 ? currentSeconds / durationSeconds : 0.0;

  PodcastPlayerState copyWith({
    PodcastEpisode? currentEpisode,
    bool? isPlaying,
    int? currentSeconds,
    double? playbackSpeed,
    bool clearEpisode = false,
  }) {
    return PodcastPlayerState(
      currentEpisode: clearEpisode ? null : (currentEpisode ?? this.currentEpisode),
      isPlaying: isPlaying ?? this.isPlaying,
      currentSeconds: currentSeconds ?? this.currentSeconds,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }
}

@riverpod
class PodcastPlayerNotifier extends _$PodcastPlayerNotifier {
  Timer? _playbackTimer;

  @override
  PodcastPlayerState build() {
    ref.onDispose(() {
      _stopTimer();
    });
    return const PodcastPlayerState();
  }

  void play(PodcastEpisode episode) {
    if (state.currentEpisode?.id == episode.id) {
      if (!state.isPlaying) {
        _startTimer();
        state = state.copyWith(isPlaying: true);
      }
      return;
    }

    _stopTimer();
    state = PodcastPlayerState(
      currentEpisode: episode,
      isPlaying: true,
      currentSeconds: 0,
      playbackSpeed: state.playbackSpeed,
    );
    _startTimer();
  }

  void togglePlayback() {
    if (state.currentEpisode == null) return;

    if (state.isPlaying) {
      _stopTimer();
      state = state.copyWith(isPlaying: false);
    } else {
      _startTimer();
      state = state.copyWith(isPlaying: true);
    }
  }

  void seek(double progressFraction) {
    if (state.currentEpisode == null) return;
    final targetSeconds = (progressFraction * state.durationSeconds).round().clamp(0, state.durationSeconds);
    state = state.copyWith(currentSeconds: targetSeconds);
  }

  void skip(int deltaSeconds) {
    if (state.currentEpisode == null) return;
    final targetSeconds = (state.currentSeconds + deltaSeconds).clamp(0, state.durationSeconds);
    state = state.copyWith(currentSeconds: targetSeconds);
  }

  void setPlaybackSpeed(double speed) {
    state = state.copyWith(playbackSpeed: speed);
    if (state.isPlaying) {
      _startTimer(); // Restart timer with adjusted speed interval if playing
    }
  }

  void reset() {
    _stopTimer();
    state = const PodcastPlayerState();
  }

  void _startTimer() {
    _playbackTimer?.cancel();
    
    // Simulate playback speed by adjusting the tick interval
    // 1.0x speed -> 1000ms tick
    // 1.25x speed -> 800ms tick
    // 1.5x speed -> 667ms tick
    // 2.0x speed -> 500ms tick
    final msInterval = (1000 / state.playbackSpeed).round();
    
    _playbackTimer = Timer.periodic(Duration(milliseconds: msInterval), (timer) {
      if (state.currentSeconds < state.durationSeconds) {
        state = state.copyWith(currentSeconds: state.currentSeconds + 1);
      } else {
        _stopTimer();
        state = state.copyWith(isPlaying: false, currentSeconds: 0);
      }
    });
  }

  void _stopTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }
}
