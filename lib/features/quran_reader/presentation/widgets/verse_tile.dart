import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for HapticFeedback
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Removed just_audio import as AudioSource is no longer needed here

import 'package:quran_flutter/core/audio/audio_player_service.dart';
import 'package:quran_flutter/core/models/verse.dart';
import 'package:quran_flutter/features/gamification/application/user_progress_provider.dart'; // Import user progress provider
import 'package:quran_flutter/features/settings/application/settings_providers.dart';
import 'package:quran_flutter/core/audio/audio_playback_notifier.dart';
import 'package:quran_flutter/core/audio/audio_progress_notifier.dart';
import 'package:quran_flutter/core/audio/playback_state.dart';
// Removed import for data_providers.dart (quranTextSourceProvider no longer needed here)
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:quran_flutter/features/quran_reader/application/providers/ai_translation_provider.dart'; // Import AI provider

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

    // Determine if bookmarked
    final bookmarks =
        ref.watch(userProgressProvider.select((up) => up.bookmarks));
    final isBookmarked = bookmarks.any((b) =>
        b['surah'] == widget.surahNumber &&
        b['verse'] == widget.verse.numberInSurah);

    // --- Define Colors and Glow ---
    final defaultCardColor = isActiveVerse
        ? colorScheme.primary.withOpacity(0.1)
        : colorScheme.surface;
    // Slightly brighter surface color for bookmarked card background
    final bookmarkedCardColor = Color.lerp(colorScheme.surface, Colors.white,
            0.15) ?? // Blend surface with white
        colorScheme.surface;
    final defaultArabicColor = colorScheme.onSurface;
    final defaultTranslationColor = colorScheme.onSurface.withOpacity(0.8);
    final defaultTransliterationColor = colorScheme.onSurface.withOpacity(0.7);
    // Brighter text colors for bookmarked state
    final bookmarkedArabicColor =
        Color.lerp(defaultArabicColor, Colors.white, 0.6) ?? Colors.white;
    final bookmarkedTranslationColor =
        Color.lerp(defaultTranslationColor, Colors.white, 0.6) ?? Colors.white;
    final bookmarkedTransliterationColor =
        Color.lerp(defaultTransliterationColor, Colors.white, 0.6) ??
            Colors.white;
    // Glow effect settings
    final glowColor = Colors.white.withOpacity(0.25); // Subtle white glow
    final textGlowShadows = [
      Shadow(color: glowColor, blurRadius: 4.0),
      Shadow(color: glowColor.withOpacity(0.15), blurRadius: 8.0),
    ];
    final cardGlowShadows = [
      BoxShadow(
        color: glowColor,
        blurRadius: 10.0,
        spreadRadius: 1.0,
      )
    ];
    // --- End Color Definitions ---

    // Original border logic for active verse (non-bookmarked state)
    // Only show active border if NOT bookmarked
    final activeVerseBorderColor = (!isBookmarked && isActiveVerse)
        ? colorScheme.primary
        : Colors.transparent;

    // Build the Arabic text widget with conditional styling
    final Widget arabicTextWidget = Text(
      widget.verse.text,
      style: GoogleFonts.amiri(
        fontSize: 22 * fontSizeScale,
        height: 1.8,
        color: isBookmarked ? bookmarkedArabicColor : defaultArabicColor,
        shadows: isBookmarked ? textGlowShadows : null,
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );

    // Build the core Card content
    Widget cardContent = Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: isActiveVerse ? 4 : 2,
      // Apply conditional background color
      color: isBookmarked ? bookmarkedCardColor : defaultCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        // Apply conditional border (only for active verse if not bookmarked)
        side: BorderSide(color: activeVerseBorderColor, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias, // Ensure content respects rounded corners
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
                  child: arabicTextWidget, // Use the styled widget
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Translation with conditional styling
            if (widget.verse.translationText != null &&
                widget.verse.translationText!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 38.0),
                child: Text(
                  widget.verse.translationText!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: isBookmarked
                        ? bookmarkedTranslationColor
                        : defaultTranslationColor,
                    fontSize:
                        (textTheme.bodyMedium?.fontSize ?? 14) * fontSizeScale,
                    shadows: isBookmarked ? textGlowShadows : null,
                  ),
                ),
              ),

            // Transliteration with conditional styling
            if (showTransliteration &&
                widget.verse.transliterationText != null &&
                widget.verse.transliterationText!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 38.0),
                child: Text(
                  widget.verse.transliterationText!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: isBookmarked
                        ? bookmarkedTransliterationColor
                        : defaultTransliterationColor,
                    fontSize:
                        (textTheme.bodyMedium?.fontSize ?? 14) * fontSizeScale,
                    shadows: isBookmarked ? textGlowShadows : null,
                  ),
                ),
              ),
            ],

            // Progress Bar / Error Display (no changes needed here)
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
              else
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
              const SizedBox(height: 8),
          ],
        ),
      ),
    );

    // Apply outer glow using DecoratedBox if bookmarked
    if (isBookmarked) {
      cardContent = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), // Match card shape
          boxShadow: cardGlowShadows,
        ),
        child: cardContent, // Wrap the original card
      );
    }

    // Build the final InkWell wrapper
    Widget verseWidget = InkWell(
      onTap: () {
        print(
          "VerseTile Tapped: Surah ${widget.surahNumber}, Verse ${widget.verse.numberInSurah}",
        );
        final currentPlaybackState = ref.read(audioPlaybackStateProvider);
        _handleTap(currentPlaybackState, currentVerseId);
      },
      onLongPress: () {
        final notifier = ref.read(userProgressProvider.notifier);
        final isBookmarkedCheck = isBookmarked; // Use already checked value

        String message;
        if (isBookmarkedCheck) {
          notifier.removeBookmark(
              widget.surahNumber, widget.verse.numberInSurah);
          message = 'Bookmark removed!';
        } else {
          notifier.addBookmark(widget.surahNumber, widget.verse.numberInSurah);
          message = 'Verse bookmarked!';
        }

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        HapticFeedback.mediumImpact();
      },
      borderRadius: BorderRadius.circular(10), // Match card shape for ripple
      child: cardContent, // Use the (potentially decorated) card content
    );

    // Wrap the InkWell with GestureDetector for swipe detection
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Check for right-to-left swipe (negative primary velocity)
        // Adjust velocity threshold as needed for sensitivity
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -300) {
          final aiEnabled = ref.read(aiTranslationEnabledProvider);
          if (aiEnabled) {
            print(
                "AI Translation swipe detected for ${widget.surahNumber}:${widget.verse.numberInSurah}");
            // Show the bottom sheet, which will trigger the fetch
            _showAiTranslationSheet(
                context, ref, widget.surahNumber, widget.verse.numberInSurah);
          } else {
            print("AI Translation swipe detected but feature is disabled.");
            // Optionally show a snackbar informing the user it's disabled
            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //   content: Text('AI Translation feature is disabled in Settings.'),
            //   duration: Duration(seconds: 2),
            // ));
          }
        }
      },
      child: verseWidget, // The existing InkWell/Card structure
    );
  } // End build method

  // --- Helper Method for Bottom Sheet ---

  void _showAiTranslationSheet(
      BuildContext context, WidgetRef ref, int surahNumber, int verseNumber) {
    final verseId = VerseIdentifier(surahNumber, verseNumber);
    // Trigger fetch *before* showing the sheet
    // Use ref.read for notifier access outside build/listen
    // Ensure fetch is only called once per sheet opening if needed (handled in notifier)
    Future.microtask(() =>
        ref.read(aiTranslationProvider(verseId).notifier).fetchTranslation());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows sheet to take more height
      backgroundColor: Theme.of(context)
          .colorScheme
          .surface
          .withOpacity(0.95), // Themed background
      shape: const RoundedRectangleBorder(
        // Rounded corners
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Use DraggableScrollableSheet for flexible height and scrolling
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4, // Start at 40% height
          minChildSize: 0.2, // Min height
          maxChildSize: 0.7, // Max height
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Optional: Add a drag handle indicator
                  Center(
                    child: Container(
                      height: 5,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    'AI Translation (Quran $surahNumber:$verseNumber)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Content area that scrolls
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController, // Link controller
                      child: Consumer(
                        builder: (context, ref, child) {
                          final translationState =
                              ref.watch(aiTranslationProvider(verseId));
                          return translationState.when(
                            data: (translation) {
                              // Handle the initial empty state vs actual data
                              if (translation.isEmpty &&
                                  !translationState.isLoading) {
                                // This state occurs before fetchTranslation completes
                                // or if fetch hasn't been called yet. Show loading.
                                return const Center(
                                    child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ));
                              }
                              return Text(
                                translation,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.9),
                                      height: 1.5, // Improve line spacing
                                    ),
                              );
                            },
                            loading: () => const Center(
                                child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            )),
                            error: (error, stack) => Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Error fetching AI translation:\n$error',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Padding at bottom
                ],
              ),
            );
          },
        );
      },
    );
  }
}
