import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_flutter/core/audio/audio_playback_notifier.dart';
import 'package:quran_flutter/core/audio/audio_progress_notifier.dart';
import 'package:quran_flutter/core/audio/playback_state.dart';
// Removed settings provider import

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final player = AudioPlayer();
  final playbackNotifier = ref.read(audioPlaybackStateProvider.notifier);
  final progressNotifier = ref.read(audioProgressProvider.notifier);

  final service = AudioPlayerService(
    player,
    playbackNotifier,
    progressNotifier,
  );

  ref.onDispose(() {
    print("Disposing AudioPlayerService and listeners");
    service.dispose();
  });

  return service;
});

class AudioPlayerService {
  final AudioPlayer _audioPlayer;
  final AudioPlaybackNotifier _playbackNotifier;
  final AudioProgressNotifier _progressNotifier;

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _bufferedPositionSubscription;

  PlayingVerseIdentifier? _currentVerseId;

  AudioPlayerService(
    this._audioPlayer,
    this._playbackNotifier,
    this._progressNotifier,
  ) {
    _audioPlayer.setLoopMode(LoopMode.off);
    _listenToPlayerStreams();
  }

  void _listenToPlayerStreams() {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen(
      (playerState) {
        _updatePlaybackStatus(playerState);
      },
      onError: (e) {
        print('Error in playerStateStream: $e');
        _playbackNotifier.setError('Player state error: $e');
        _resetInternalState();
      },
    );

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (_currentVerseId != null &&
          (_playbackNotifier.state.status == PlaybackStatus.playing ||
              _playbackNotifier.state.status == PlaybackStatus.paused)) {
        _progressNotifier.updateProgress(
          position,
          _audioPlayer.bufferedPosition,
          _audioPlayer.duration ?? Duration.zero,
        );
      }
    });

    _bufferedPositionSubscription = _audioPlayer.bufferedPositionStream.listen((
      buffered,
    ) {
      if (_currentVerseId != null &&
          (_playbackNotifier.state.status == PlaybackStatus.playing ||
              _playbackNotifier.state.status == PlaybackStatus.paused)) {
        _progressNotifier.updateProgress(
          _audioPlayer.position,
          buffered,
          _audioPlayer.duration ?? Duration.zero,
        );
      }
    });

    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (_currentVerseId != null &&
          (_playbackNotifier.state.status == PlaybackStatus.playing ||
              _playbackNotifier.state.status == PlaybackStatus.paused)) {
        _progressNotifier.updateProgress(
          _audioPlayer.position,
          _audioPlayer.bufferedPosition,
          duration ?? Duration.zero,
        );
      }
    });
  }

  // Restore completion handling via stream listener
  void _updatePlaybackStatus(PlayerState playerState) {
    final isPlaying = playerState.playing;
    final processingState = playerState.processingState;
    // Use the internally tracked _currentVerseId

    print(
      'Player State Update: playing=$isPlaying, processing=$processingState, currentVerseId=$_currentVerseId',
    );

    // --- Handle Completion ---
    if (processingState == ProcessingState.completed) {
      final completedVerseId =
          _currentVerseId; // Capture before potential change
      print('Processing state completed for verse: $completedVerseId');

      // Only update state if we haven't already marked as completed
      // and if the completed verse matches the one we were tracking.
      if (_playbackNotifier.state.status != PlaybackStatus.completed &&
          completedVerseId != null) {
        print(
          'AudioService: Detected completion for $completedVerseId. Calling notifier.setCompleted()',
        );
        // Pass the ID of the completed verse to the notifier
        _playbackNotifier.setCompleted(completedVerseId);
        _progressNotifier.reset();
        _currentVerseId = null; // Clear internal ID *after* notifying
        // Autoplay logic is external in AppLifecycleObserver
      } else if (completedVerseId == null &&
          _playbackNotifier.state.status != PlaybackStatus.idle) {
        // If completion happens when we don't expect it (no currentVerseId), go idle.
        print(
          "AudioService: Completion event received while _currentVerseId is null. Setting state to idle.",
        );
        _playbackNotifier.setIdle();
        _progressNotifier.reset();
      }
    }
    // --- Handle Loading/Buffering ---
    else if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      if (_currentVerseId != null) {
        // Only update to loading if not already playing/paused
        if (_playbackNotifier.state.status != PlaybackStatus.playing &&
            _playbackNotifier.state.status != PlaybackStatus.paused) {
          _playbackNotifier.setLoading(_currentVerseId!);
        }
      }
    }
    // --- Handle Playing ---
    else if (isPlaying) {
      if (_currentVerseId != null) {
        // Only update to playing if not already playing
        if (_playbackNotifier.state.status != PlaybackStatus.playing) {
          _playbackNotifier.setPlaying(_currentVerseId!);
        }
      } else {
        print(
          "Warning: Player is playing but _currentVerseId is null. Stopping.",
        );
        stop();
      }
    }
    // --- Handle Paused ---
    else if (!isPlaying && processingState == ProcessingState.ready) {
      if (_playbackNotifier.state.status == PlaybackStatus.playing ||
          _playbackNotifier.state.status == PlaybackStatus.loading) {
        _playbackNotifier.setPaused();
      }
    }
    // --- Handle Idle (after stop or initial state) ---
    else if (processingState == ProcessingState.idle) {
      if (_playbackNotifier.state.status != PlaybackStatus.idle) {
        _playbackNotifier.setIdle();
        // Ensure ID is cleared when going idle
        if (_currentVerseId != null) {
          _resetInternalState();
        }
      }
    }
  }

  /// Plays audio from the given URL for a specific verse.
  Future<void> playVerse(String? url, int surahNumber, int verseNumber) async {
    final verseId = PlayingVerseIdentifier(surahNumber, verseNumber);
    _currentVerseId = verseId; // Update current ID immediately
    print('AudioService: playVerse called for $verseId');

    if (url == null || url.isEmpty) {
      print('Audio URL is null or empty for $verseId, cannot play.');
      _playbackNotifier.setError('Invalid audio source.');
      _resetInternalState();
      return;
    }

    _playbackNotifier.setLoading(verseId); // Set loading state

    try {
      // Stop is important to cancel potential previous loading/playing
      await _audioPlayer.stop();
      // await Future.delayed(const Duration(milliseconds: 50)); // Removed delay
      _progressNotifier.reset();
      await _audioPlayer.setUrl(url);
      await _audioPlayer.setLoopMode(LoopMode.off); // Ensure single play

      print('Playback initiated for: $verseId');
      // Don't await play() here, let the stream listener handle state changes including completion
      _audioPlayer.play();
    } on PlayerException catch (e) {
      print('PlayerException playing verse $verseId: ${e.message}');
      _playbackNotifier.setError('Error loading audio: ${e.message}');
      _resetInternalState();
    } on PlayerInterruptedException catch (e) {
      // This happens if stop() is called during playback/loading
      print('PlayerInterruptedException playing verse $verseId: ${e.message}');
      // State should be handled by the stop() call setting it to idle.
      // Reset internal state just in case.
      if (_currentVerseId == verseId) {
        _resetInternalState();
      }
    } catch (e, s) {
      print('Generic error playing verse $verseId: $e');
      print(s);
      _playbackNotifier.setError('An unexpected error occurred.');
      _resetInternalState();
    }
  }

  Future<void> pause() async {
    if (_playbackNotifier.state.status == PlaybackStatus.playing) {
      try {
        await _audioPlayer.pause();
        print('Pause requested for verse: $_currentVerseId');
        // State update handled by stream listener
      } catch (e) {
        print('Error pausing audio: $e');
        _playbackNotifier.setError('Failed to pause.');
      }
    }
  }

  Future<void> resume() async {
    if (_playbackNotifier.state.status == PlaybackStatus.paused &&
        _currentVerseId != null) {
      try {
        await _audioPlayer.play();
        print('Resume requested for verse: $_currentVerseId');
        // State update handled by stream listener
      } catch (e) {
        print('Error resuming audio: $e');
        _playbackNotifier.setError('Failed to resume.');
      }
    } else {
      print('Cannot resume: Not paused or no current verse ID.');
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      print('Stop requested');
      _resetInternalState();
      _playbackNotifier.setIdle(); // Explicitly set to idle
    } catch (e) {
      print('Error stopping audio: $e');
      _playbackNotifier.setError('Failed to stop playback.');
      _resetInternalState(); // Ensure reset even on error
    }
  }

  void _resetInternalState() {
    _currentVerseId = null;
    _progressNotifier.reset();
  }

  Future<void> seek(Duration position) async {
    if (_playbackNotifier.state.status == PlaybackStatus.playing ||
        _playbackNotifier.state.status == PlaybackStatus.paused) {
      try {
        await _audioPlayer.seek(position);
        print('Seek requested to $position');
      } catch (e) {
        print('Error seeking audio: $e');
        _playbackNotifier.setError('Failed to seek.');
      }
    } else {
      print('Cannot seek: Player not in playing/paused state.');
    }
  }

  void dispose() {
    print("Disposing AudioPlayerService subscriptions");
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _bufferedPositionSubscription?.cancel();
    _audioPlayer.dispose();
  }
}
