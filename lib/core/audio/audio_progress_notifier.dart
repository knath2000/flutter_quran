import 'package:flutter_riverpod/flutter_riverpod.dart';

// State class for audio progress
class AudioProgressState {
  final Duration currentPosition;
  final Duration bufferedPosition;
  final Duration totalDuration;

  const AudioProgressState({
    this.currentPosition = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.totalDuration = Duration.zero,
  });

  AudioProgressState copyWith({
    Duration? currentPosition,
    Duration? bufferedPosition,
    Duration? totalDuration,
  }) {
    return AudioProgressState(
      currentPosition: currentPosition ?? this.currentPosition,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioProgressState &&
          runtimeType == other.runtimeType &&
          currentPosition == other.currentPosition &&
          bufferedPosition == other.bufferedPosition &&
          totalDuration == other.totalDuration;

  @override
  int get hashCode =>
      currentPosition.hashCode ^
      bufferedPosition.hashCode ^
      totalDuration.hashCode;

  @override
  String toString() {
    return 'AudioProgressState{currentPosition: $currentPosition, bufferedPosition: $bufferedPosition, totalDuration: $totalDuration}';
  }
}

// StateNotifier for managing audio progress
class AudioProgressNotifier extends StateNotifier<AudioProgressState> {
  AudioProgressNotifier() : super(const AudioProgressState());

  // Method to update the progress state - called by AudioPlayerService
  void updateProgress(Duration current, Duration buffered, Duration total) {
    // Avoid unnecessary updates if values haven't changed significantly
    if (state.currentPosition != current ||
        state.bufferedPosition != buffered ||
        state.totalDuration != total) {
      state = state.copyWith(
        currentPosition: current,
        bufferedPosition: buffered,
        totalDuration: total,
      );
    }
  }

  void reset() {
    state = const AudioProgressState();
  }
}

// Provider for the AudioProgressNotifier
final audioProgressProvider =
    StateNotifierProvider<AudioProgressNotifier, AudioProgressState>((ref) {
      return AudioProgressNotifier();
    });
