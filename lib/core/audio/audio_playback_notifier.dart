import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/core/audio/playback_state.dart';

// StateNotifier for managing the audio playback state
class AudioPlaybackNotifier extends StateNotifier<AudioPlaybackState> {
  AudioPlaybackNotifier() : super(const AudioPlaybackState());

  // Internal methods to update state - called by AudioPlayerService

  void setIdle() {
    state = state.copyWith(
      status: PlaybackStatus.idle,
      clearPlayingVerseId: true,
      clearErrorMessage: true,
    );
  }

  void setLoading(PlayingVerseIdentifier verseId) {
    state = state.copyWith(
      status: PlaybackStatus.loading,
      playingVerseId: verseId, // Set which verse is loading
      clearErrorMessage: true,
    );
  }

  void setPlaying(PlayingVerseIdentifier verseId) {
    state = state.copyWith(
      status: PlaybackStatus.playing,
      playingVerseId: verseId, // Ensure playing ID is set
      clearErrorMessage: true,
    );
  }

  void setPaused() {
    // Keep playingVerseId when paused
    if (state.status == PlaybackStatus.playing ||
        state.status == PlaybackStatus.loading) {
      state = state.copyWith(
        status: PlaybackStatus.paused,
        clearErrorMessage: true,
      );
    }
  }

  void setCompleted(PlayingVerseIdentifier completedVerseId) {
    // Keep the ID of the completed verse in the state temporarily
    // so the observer can read it. It will be cleared on the next state change (e.g., idle, loading, playing).
    print(
      'AudioPlaybackNotifier: Setting state to completed for $completedVerseId. Previous state: ${state.status}',
    );
    state = state.copyWith(
      status: PlaybackStatus.completed,
      playingVerseId: completedVerseId, // Store the completed ID
      clearErrorMessage: true,
    );
  }

  void setError(String message) {
    state = state.copyWith(
      status: PlaybackStatus.error,
      errorMessage: message,
      clearPlayingVerseId: true, // Clear playing ID on error
    );
  }
}

// Provider for the AudioPlaybackNotifier
final audioPlaybackStateProvider =
    StateNotifierProvider<AudioPlaybackNotifier, AudioPlaybackState>((ref) {
      return AudioPlaybackNotifier();
    });
