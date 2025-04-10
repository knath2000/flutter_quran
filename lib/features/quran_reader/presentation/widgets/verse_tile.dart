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
import 'package:quran_flutter/core/providers/data_providers.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

// Provider to fetch Arabic text specifically from the JSON source (if available)
final arabicJsonTextProvider =
    FutureProvider.family<String?, PlayingVerseIdentifier>((
      ref,
      verseId,
    ) async {
      // Ensure the initializer has finished before proceeding
      await ref.watch(jsonDataSourceInitializerProvider.future);

      // Now read the source (it might be null if not on Web/macOS)
      final jsonSource = ref.read(quranTextSourceProvider);
      if (jsonSource != null) {
        // Initialization is guaranteed complete by the await above
        return await jsonSource.getArabicVerseText(
          verseId.surahNumber,
          verseId.verseNumber,
        );
      }
      return null; // Return null if JSON source is not applicable
    });

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
    print("_handleTap called for ${currentVerseId}");
    final audioService = ref.read(audioPlayerServiceProvider);
    final isCurrentlyPlaying =
        playbackState.status == PlaybackStatus.playing &&
        playbackState.playingVerseId == currentVerseId;
    final isCurrentlyPaused =
        playbackState.status == PlaybackStatus.paused &&
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
    final jsonSource = ref.watch(
      quranTextSourceProvider,
    ); // Check if JSON source is available

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

    final cardColor =
        isActiveVerse
            ? colorScheme.primary.withOpacity(0.1)
            : colorScheme.surface;
    final borderColor =
        isActiveVerse ? colorScheme.primary : Colors.transparent;

    // Widget to display Arabic text (conditionally loaded)
    Widget arabicTextWidget;
    if (jsonSource != null) {
      // Use JSON source on Web/macOS
      final arabicTextAsync = ref.watch(arabicJsonTextProvider(currentVerseId));
      arabicTextWidget = arabicTextAsync.when(
        data:
            (text) => Text(
              text ??
                  widget
                      .verse
                      .text, // Fallback to verse.text if JSON lookup fails
              style: GoogleFonts.amiri(
                fontSize: 22 * fontSizeScale,
                height: 1.8,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
        loading:
            () => const SizedBox(
              // Simple loading indicator
              height: 30, // Approx height of text
              width: 30,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        error:
            (err, stack) => Text(
              'Error loading text',
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 14 * fontSizeScale,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
      );
    } else {
      // Use API source (already in verse object) on iOS/Other
      arabicTextWidget = Text(
        widget.verse.text,
        style: GoogleFonts.amiri(
          fontSize: 22 * fontSizeScale,
          height: 1.8,
          color: colorScheme.onSurface,
        ),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
      );
    }

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
                      fontSize:
                          (textTheme.bodyMedium?.fontSize ?? 14) *
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
                    style: textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontSize:
                          (textTheme.bodySmall?.fontSize ?? 12) * fontSizeScale,
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
