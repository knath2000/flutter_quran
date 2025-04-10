import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Removed just_audio import as AudioSource is no longer needed here
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import 'package:quran_flutter/core/audio/audio_player_service.dart';
import 'package:quran_flutter/core/models/verse.dart';
import 'package:quran_flutter/features/settings/application/settings_providers.dart';
import 'package:quran_flutter/core/audio/audio_playback_notifier.dart';
import 'package:quran_flutter/core/audio/audio_progress_notifier.dart';
import 'package:quran_flutter/core/audio/playback_state.dart';
// Removed import for data_providers.dart (quranTextSourceProvider no longer needed here)
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

// Removed arabicJsonTextProvider as JSON text source is no longer used

class VerseTile extends ConsumerStatefulWidget {
  final Verse verse;
  final int surahNumber;
  // Removed totalVerses and verseAudioUrls parameters

  const VerseTile({super.key, required this.verse, required this.surahNumber});

  @override
  ConsumerState<VerseTile> createState() => _VerseTileState();
}

class _VerseTileState extends ConsumerState<VerseTile> {
  void _handleTap(
    AudioPlaybackState playbackState,
    PlayingVerseIdentifier currentVerseId,
  ) {
    print("_handleTap called for $currentVerseId");
    final audioService = ref.read(audioPlayerServiceProvider);
    final isCurrentlyPlaying = playbackState.status == PlaybackStatus.playing &&
        playbackState.playingVerseId == currentVerseId;
    final isCurrentlyPaused = playbackState.status == PlaybackStatus.paused &&
        playbackState.playingVerseId == currentVerseId;

    print(
      "_handleTap: isPlaying=$isCurrentlyPlaying, isPaused=$isCurrentlyPaused",
    );
    if (isCurrentlyPlaying) {
      audioService.pause();
    } else if (isCurrentlyPaused) {
      audioService.resume();
    } else {
      print("_handleTap: Neither playing nor paused, calling playVerse...");
      // If idle, completed, error, or different verse playing, start this verse
      audioService.playVerse(
        // Call playVerse now
        widget.verse.audioUrl,
        widget.surahNumber,
        widget.verse.numberInSurah,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final fontSizeScale = ref.watch(fontSizeScaleFactorProvider);

    final playbackState = ref.watch(audioPlaybackStateProvider);
    final progressState = ref.watch(audioProgressProvider);
    final showTransliteration = ref.watch(
      showTransliterationProvider,
    ); // Watch the setting
    // Removed watch for quranTextSourceProvider (no longer needed)

    final currentVerseId = PlayingVerseIdentifier(
      widget.surahNumber,
      widget.verse.numberInSurah,
    );
    final bool isActiveVerse = playbackState.playingVerseId == currentVerseId;
    final bool isPlaying =
        isActiveVerse && playbackState.status == PlaybackStatus.playing;
    final bool isPaused =
        isActiveVerse && playbackState.status == PlaybackStatus.paused;
    final bool isLoading =
        isActiveVerse && playbackState.status == PlaybackStatus.loading;
    final bool hasError =
        isActiveVerse && playbackState.status == PlaybackStatus.error;

    final cardColor = isActiveVerse
        ? colorScheme.primary.withOpacity(0.1)
        : colorScheme.surface;
    final borderColor =
        isActiveVerse ? colorScheme.primary : Colors.transparent;

    // Always display Arabic text from the verse object (populated by API/cache)
    final Widget arabicTextWidget = Text(
      widget.verse.text,
      style: GoogleFonts.amiri(
        fontSize: 22 * fontSizeScale,
        height: 1.8,
        color: colorScheme.onSurface,
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );

    return InkWell(
      onTap: () {
        print(
          "VerseTile Tapped: Surah ${widget.surahNumber}, Verse ${widget.verse.numberInSurah}",
        );
        final currentPlaybackState = ref.read(audioPlaybackStateProvider);
        _handleTap(currentPlaybackState, currentVerseId);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        elevation: isActiveVerse ? 4 : 2,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: colorScheme.primary.withOpacity(
                      isActiveVerse ? 0.3 : 0.15,
                    ),
                    child: Text(
                      widget.verse.numberInSurah.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: arabicTextWidget, // Use the conditional widget here
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Translation
              if (widget.verse.translationText != null &&
                  widget.verse.translationText!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 38.0),
                  child: Text(
                    widget.verse.translationText!,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.8),
                      fontSize: (textTheme.bodyMedium?.fontSize ?? 14) *
                          fontSizeScale,
                    ),
                  ),
                ),

              // Transliteration
              // Conditionally display Transliteration based on setting and availability
              if (showTransliteration &&
                  widget.verse.transliterationText != null &&
                  widget.verse.transliterationText!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 38.0),
                  child: Text(
                    widget.verse.transliterationText!,
                    textAlign: TextAlign.center, // Center align the text
                    style: textTheme.bodyMedium?.copyWith(
                      // Use bodyMedium style like translation
                      // fontStyle: FontStyle.italic, // Remove italic
                      color: colorScheme.onSurface.withOpacity(
                        0.7,
                      ), // Slightly less prominent than translation
                      fontSize: (textTheme.bodyMedium?.fontSize ?? 14) *
                          fontSizeScale, // Match translation size base
                    ),
                  ),
                ),
              ],

              // Progress Bar / Error Display
              if (isActiveVerse &&
                  widget.verse.audioUrl != null &&
                  widget.verse.audioUrl!.isNotEmpty) ...[
                const SizedBox(height: 10),
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      playbackState.errorMessage ?? 'Audio error',
                      style: TextStyle(color: colorScheme.error, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  )
                else // Show progress bar if active and not errored
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: ProgressBar(
                      progress: progressState.currentPosition,
                      buffered: progressState.bufferedPosition,
                      total: progressState.totalDuration,
                      onSeek: (duration) {
                        ref.read(audioPlayerServiceProvider).seek(duration);
                      },
                      progressBarColor: colorScheme.primary,
                      baseBarColor: colorScheme.onSurface.withOpacity(0.2),
                      bufferedBarColor: colorScheme.primary.withOpacity(0.3),
                      thumbColor: colorScheme.primary.withOpacity(0.8),
                      thumbRadius: 6,
                      timeLabelTextStyle: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ] else if (widget.verse.audioUrl == null ||
                  widget.verse.audioUrl!.isEmpty)
                const SizedBox(height: 8), // Maintain spacing if no audio
            ], // End main Column children
          ), // End Padding
        ), // End Card
      ), // End InkWell
    );
  }
}
