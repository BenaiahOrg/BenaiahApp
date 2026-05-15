import 'dart:async';
import 'dart:developer' as developer;
import 'package:benaiah_app/features/podcast/domain/entities/podcast_episode.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_player_notifier.g.dart';

class PodcastPlayerState {
  const PodcastPlayerState({
    this.currentEpisode,
    this.isPlaying = false,
    this.currentSeconds = 0,
    this.playbackSpeed = 1.0,
    this.isBuffering = false,
  });

  final PodcastEpisode? currentEpisode;
  final bool isPlaying;
  final int currentSeconds;
  final double playbackSpeed;
  final bool isBuffering;

  int get durationSeconds => currentEpisode?.durationSeconds ?? 0;
  double get progress =>
      durationSeconds > 0 ? currentSeconds / durationSeconds : 0.0;

  PodcastPlayerState copyWith({
    PodcastEpisode? currentEpisode,
    bool? isPlaying,
    int? currentSeconds,
    double? playbackSpeed,
    bool? isBuffering,
    bool clearEpisode = false,
  }) {
    return PodcastPlayerState(
      currentEpisode: clearEpisode
          ? null
          : (currentEpisode ?? this.currentEpisode),
      isPlaying: isPlaying ?? this.isPlaying,
      currentSeconds: currentSeconds ?? this.currentSeconds,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isBuffering: isBuffering ?? this.isBuffering,
    );
  }
}

@riverpod
class PodcastPlayerNotifier extends _$PodcastPlayerNotifier {
  late final AudioPlayer _audioPlayer;
  final _storage = const FlutterSecureStorage();
  StreamSubscription<Duration?>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  Timer? _persistenceTimer;

  @override
  PodcastPlayerState build() {
    _audioPlayer = AudioPlayer();

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (state.currentEpisode != null) {
        state = state.copyWith(currentSeconds: position.inSeconds);
      }
    });

    _playerStateSubscription = _audioPlayer.playerStateStream.listen((
      playerState,
    ) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      state = state.copyWith(
        isPlaying: isPlaying,
        isBuffering:
            processingState == ProcessingState.buffering ||
            processingState == ProcessingState.loading,
      );

      if (processingState == ProcessingState.completed) {
        unawaited(_audioPlayer.pause());
        unawaited(_audioPlayer.seek(Duration.zero));
        state = state.copyWith(isPlaying: false, currentSeconds: 0);
        unawaited(_clearPersistedPosition());
      }
    });

    _persistenceTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (state.isPlaying) {
        unawaited(_saveCurrentPosition());
      }
    });

    ref.onDispose(() {
      _persistenceTimer?.cancel();
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

    // Save previous episode position before switching
    if (state.currentEpisode != null) {
      await _saveCurrentPosition();
    }

    state = PodcastPlayerState(
      currentEpisode: episode,
      playbackSpeed: state.playbackSpeed,
    );

    try {
      final audioSource = AudioSource.uri(
        Uri.parse(episode.audioUrl),
        tag: MediaItem(
          id: episode.id,
          album: 'Benaiah Podcast',
          title: episode.title,
          artist: episode.hosts.map((h) => h.name).join(', '),
          artUri: episode.imageUrl.isNotEmpty
              ? Uri.parse(episode.imageUrl)
              : null,
        ),
      );

      await _audioPlayer.setAudioSource(audioSource);
      await _audioPlayer.setSpeed(state.playbackSpeed);

      // Restore position if available
      final savedPos = await _storage.read(key: 'podcast_pos_${episode.id}');
      if (savedPos != null) {
        final seconds = int.tryParse(savedPos) ?? 0;
        if (seconds > 0 && seconds < episode.durationSeconds - 5) {
          await _audioPlayer.seek(Duration(seconds: seconds));
        }
      }

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
      await _saveCurrentPosition();
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
    await _saveCurrentPosition();
  }

  Future<void> skip(int deltaSeconds) async {
    if (state.currentEpisode == null) return;
    final targetSeconds = (state.currentSeconds + deltaSeconds).clamp(
      0,
      state.durationSeconds,
    );
    await _audioPlayer.seek(Duration(seconds: targetSeconds));
    await _saveCurrentPosition();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    state = state.copyWith(playbackSpeed: speed);
    await _audioPlayer.setSpeed(speed);
  }

  Future<void> reset() async {
    await _saveCurrentPosition();
    await _audioPlayer.stop();
    state = const PodcastPlayerState();
  }

  Future<void> _saveCurrentPosition() async {
    final episode = state.currentEpisode;
    if (episode != null && state.currentSeconds > 0) {
      await _storage.write(
        key: 'podcast_pos_${episode.id}',
        value: state.currentSeconds.toString(),
      );
    }
  }

  Future<void> _clearPersistedPosition() async {
    final episode = state.currentEpisode;
    if (episode != null) {
      await _storage.delete(key: 'podcast_pos_${episode.id}');
    }
  }
}
