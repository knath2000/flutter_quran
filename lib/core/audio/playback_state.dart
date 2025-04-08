enum PlaybackStatus { idle, loading, playing, paused, completed, error }

class PlayingVerseIdentifier {
  final int surahNumber;
  final int verseNumber;

  const PlayingVerseIdentifier(this.surahNumber, this.verseNumber);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayingVerseIdentifier &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          verseNumber == other.verseNumber;

  @override
  int get hashCode => surahNumber.hashCode ^ verseNumber.hashCode;

  @override
  String toString() {
    return 'PlayingVerseIdentifier{surahNumber: $surahNumber, verseNumber: $verseNumber}';
  }
}

class AudioPlaybackState {
  final PlaybackStatus status;
  final PlayingVerseIdentifier? playingVerseId;
  final String? errorMessage;

  const AudioPlaybackState({
    this.status = PlaybackStatus.idle,
    this.playingVerseId,
    this.errorMessage,
  });

  AudioPlaybackState copyWith({
    PlaybackStatus? status,
    PlayingVerseIdentifier? playingVerseId,
    bool clearPlayingVerseId = false, // Flag to explicitly clear the ID
    String? errorMessage,
    bool clearErrorMessage = false, // Flag to explicitly clear the error
  }) {
    return AudioPlaybackState(
      status: status ?? this.status,
      playingVerseId:
          clearPlayingVerseId ? null : playingVerseId ?? this.playingVerseId,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioPlaybackState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          playingVerseId == other.playingVerseId &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      status.hashCode ^ playingVerseId.hashCode ^ errorMessage.hashCode;

  @override
  String toString() {
    return 'AudioPlaybackState{status: $status, playingVerseId: $playingVerseId, errorMessage: $errorMessage}';
  }
}
