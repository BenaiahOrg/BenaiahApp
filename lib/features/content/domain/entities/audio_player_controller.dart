import 'dart:async';
import 'package:flutter/material.dart';

class AudioPlayerController {
  AudioPlayerController({
    required this.title,
    required this.subtitle,
    required this.totalDurationSeconds,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final int totalDurationSeconds;
  final String imageUrl;

  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<double> sliderValue = ValueNotifier(0);
  final ValueNotifier<int> currentSeconds = ValueNotifier(0);

  Timer? _playbackTimer;

  void togglePlayback() {
    isPlaying.value = !isPlaying.value;
    if (isPlaying.value) {
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  void _startTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentSeconds.value < totalDurationSeconds) {
        currentSeconds.value++;
        sliderValue.value = currentSeconds.value / totalDurationSeconds;
      } else {
        resetPlayback();
      }
    });
  }

  void _stopTimer() {
    _playbackTimer?.cancel();
  }

  void resetPlayback() {
    isPlaying.value = false;
    currentSeconds.value = 0;
    sliderValue.value = 0;
    _stopTimer();
  }

  void seek(double value) {
    sliderValue.value = value;
    currentSeconds.value = (value * totalDurationSeconds).round();
  }

  void skipSeconds(int delta) {
    currentSeconds.value = (currentSeconds.value + delta).clamp(
      0,
      totalDurationSeconds,
    );
    sliderValue.value = currentSeconds.value / totalDurationSeconds;
  }

  void dispose() {
    _playbackTimer?.cancel();
    isPlaying.dispose();
    sliderValue.dispose();
    currentSeconds.dispose();
  }
}
