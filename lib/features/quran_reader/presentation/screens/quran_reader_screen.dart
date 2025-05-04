import 'dart:async'; // For Timer (debouncing)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/core/audio/audio_player_service.dart';
import 'package:quran_flutter/features/gamification/application/user_progress_provider.dart'; // Needed for last read update
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart'; // Import the package
import 'package:quran_flutter/core/audio/audio_playback_notifier.dart'; // Import playback state
import 'package:quran_flutter/core/audio/playback_state.dart'; // Import playback status enum
import 'package:quran_flutter/core/models/surah_info.dart'; // Import SurahInfo
import 'package:quran_flutter/core/models/verse.dart';
import 'package:quran_flutter/features/quran_reader/application/providers/surah_details_provider.dart';
import 'package:quran_flutter/features/quran_reader/application/providers/surah_list_provider.dart';
// Removed unused import for surah_introduction_provider.dart
import 'package:quran_flutter/features/quran_reader/presentation/widgets/surah_introduction_card.dart';
import 'package:quran_flutter/features/quran_reader/presentation/widgets/verse_tile.dart';
import 'package:quran_flutter/features/settings/application/settings_providers.dart';
import 'package:quran_flutter/shared/widgets/starry_background.dart';

// Convert to ConsumerStatefulWidget to use initState
class QuranReaderScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  final String? surahName; // Keep optional surahName

  const QuranReaderScreen({
    super.key,
    required this.surahNumber,
    this.surahName,
  });

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  // Controllers for ScrollablePositionedList
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  Timer? _debounce; // Timer for debouncing scroll updates

  @override
  void initState() {
    super.initState();

    // Add listener for scroll position changes
    itemPositionsListener.itemPositions.addListener(_updateLastReadPosition);

    // Fetch surah details when the screen initializes
    // Use ref.read as we only need the notifier instance, not rebuild on change
    // Use addPostFrameCallback to ensure context/ref is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Check if widget is still mounted before accessing ref
        if (!mounted) return;

        // Fetch Surah details first
        ref
            .read(surahDetailsProvider(widget.surahNumber).notifier)
            .fetchSurah();

        // Then attempt auto-scroll
        _attemptAutoScroll();
      }
    });
  }

  void _attemptAutoScroll() {
    // Ensure the widget is still mounted and controllers are ready
    if (!mounted || !itemScrollController.isAttached) {
      // Try again slightly later if not attached yet
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && !itemScrollController.isAttached) {
          print("ItemScrollController still not attached after delay.");
        } else if (mounted) {
          _attemptAutoScroll(); // Retry
        }
      });
      return;
    }

    final shouldContinue =
        ref.read(continueLastReadProvider); // Correct provider name
    if (shouldContinue) {
      final lastIndex = ref
          .read(userProgressProvider.notifier)
          .getLastReadVerseIndex(widget.surahNumber);
      // Add 1 to the verse index because item 0 is the introduction card
      final targetItemIndex = (lastIndex != null) ? lastIndex + 1 : null;

      if (targetItemIndex != null) {
        print(
            "Attempting to scroll to last read item index: $targetItemIndex (Verse index: $lastIndex)");
        // Use jumpTo for immediate scrolling
        itemScrollController.jumpTo(
          index: targetItemIndex,
          alignment: 0, // Align to the top
        );
      } else {
        print("No last read index found for Surah ${widget.surahNumber}.");
      }
    } else {
      print("Continue last read setting is off.");
    }
  }

  void _updateLastReadPosition() {
    if (!mounted) return; // Check if mounted

    // Debounce the update
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return; // Check again after delay

      final shouldUpdate =
          ref.read(continueLastReadProvider); // Correct provider name
      if (!shouldUpdate) return; // Only update if setting is enabled

      final positions = itemPositionsListener.itemPositions.value;
      if (positions.isNotEmpty) {
        // Find the index of the item whose leading edge is closest to the top (0.0)
        // Filter out the introduction card (index 0) unless it's the only thing visible
        final relevantPositions =
            positions.where((pos) => pos.index > 0 || positions.length == 1);
        if (relevantPositions.isEmpty) return; // No verses visible

        final topmostVerseItem = relevantPositions
            .reduce((a, b) => a.itemLeadingEdge < b.itemLeadingEdge ? a : b);

        // Subtract 1 from item index to get the verse index
        final topmostVerseIndex = topmostVerseItem.index - 1;

        // Ensure index is valid (not negative from intro card logic)
        if (topmostVerseIndex >= 0) {
          // Call the notifier method
          ref
              .read(userProgressProvider.notifier)
              .updateLastReadVerse(widget.surahNumber, topmostVerseIndex);
        }
      }
    });
  }

  @override
  void dispose() {
    itemPositionsListener.itemPositions.removeListener(_updateLastReadPosition);
    _debounce?.cancel(); // Cancel timer on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers needed for UI and actions
    final surahDetailsAsync = ref.watch(
      surahDetailsProvider(widget.surahNumber),
    );
    final isAutoplayOn = ref.watch(autoplayEnabledProvider);
    final audioService = ref.read(audioPlayerServiceProvider);
    final playbackState = ref.watch(
      audioPlaybackStateProvider,
    ); // Watch playback state
    final surahListAsync = ref.watch(
      surahListProvider,
    ); // Still needed for name
    // Derive introduction AsyncValue from the main details provider
    // Derive introduction AsyncValue from the main details provider
    final AsyncValue<String?> introductionAsyncValue = surahDetailsAsync.when(
      data: (data) => AsyncValue<String?>.data(data.$2), // Explicitly type data
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
    );

    // *** Add listener for auto-scrolling ***
    ref.listen<AudioPlaybackState>(audioPlaybackStateProvider,
        (previous, next) {
      // Check if the verse ID actually changed and is valid
      if (next.playingVerseId != null &&
          previous?.playingVerseId != next.playingVerseId) {
        final verseId = next.playingVerseId!;
        print(
            "Playback state changed to: Surah ${verseId.surahNumber}, Verse ${verseId.verseNumber}"); // Corrected property

        // Check if the playing verse belongs to the currently displayed Surah
        if (verseId.surahNumber == widget.surahNumber) {
          // Target index in ScrollablePositionedList is verse number (1-based)
          // because index 0 is the introduction card.
          final targetItemIndex = verseId.verseNumber; // Corrected property

          // Check if controller is attached before scrolling
          if (itemScrollController.isAttached) {
            // Check if the target index is valid within the list bounds
            // Need access to the number of verses + 1 (for intro card)
            // We can get this from the surahDetailsAsync data state if available
            surahDetailsAsync.whenData((data) {
              final totalItems =
                  data.$1.length + 1; // verses.length + intro card
              if (targetItemIndex >= 0 && targetItemIndex < totalItems) {
                print(
                    "Auto-scrolling to item index: $targetItemIndex (Verse ${verseId.verseNumber})"); // Corrected property
                itemScrollController.scrollTo(
                  index: targetItemIndex,
                  duration: const Duration(
                      milliseconds: 600), // Slightly longer duration
                  curve: Curves.easeInOutCubic,
                  alignment: 0.3, // Position 30% from the top
                );
              } else {
                print(
                    "Target index $targetItemIndex out of bounds (Total items: $totalItems)");
              }
            });
          } else {
            print(
                "ItemScrollController not attached when trying to auto-scroll.");
            // Optionally, schedule a post-frame callback to retry, though might be complex
          }
        } else {
          print(
              "Playing verse (${verseId.surahNumber}:${verseId.verseNumber}) is not in the current Surah (${widget.surahNumber}). No auto-scroll."); // Corrected property
        }
      }
    });
    // *** End listener ***

    return Scaffold(
      appBar: AppBar(
        // Use surahListProvider to get the name for the title
        title: surahListAsync.when(
          data: (list) {
            final info = list.firstWhere(
              (s) => s.number == widget.surahNumber,
              orElse: () => SurahInfo(
                number: widget.surahNumber,
                name: 'Surah ${widget.surahNumber}',
                englishName: widget.surahName ?? 'Surah ${widget.surahNumber}',
                englishNameTranslation: '',
                revelationType: '',
                numberOfAyahs: 0,
              ),
            );
            return Text(info.englishName); // Display English Name
          },
          loading: () =>
              Text(widget.surahName ?? 'Surah ${widget.surahNumber}'),
          error: (_, __) =>
              Text(widget.surahName ?? 'Surah ${widget.surahNumber}'),
        ),
        actions: [
          // Conditionally display Autoplay Indicator
          if (isAutoplayOn)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.playlist_play,
                color: Theme.of(context).colorScheme.primary,
                semanticLabel: 'Autoplay Enabled',
              ),
            ),
          // Conditionally display Stop Button only if playing or paused
          if (playbackState.status == PlaybackStatus.playing ||
              playbackState.status == PlaybackStatus.paused)
            IconButton(
              icon: const Icon(Icons.stop_circle),
              tooltip: 'Stop Playback',
              onPressed: () {
                audioService.stop();
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          StarryBackground(
            starColor: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            numberOfStars: 100,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.6),
                  Theme.of(context).colorScheme.surface.withOpacity(0.85),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ), // Add comma here
          // Directly use the AsyncValue builder for the main content list
          surahDetailsAsync.when(
            // Accept the record as 'data'
            data: (data) {
              // Access verses using data.$1
              final verses = data.$1;
              // Access introduction using data.$2 (used in SurahIntroductionCard)

              if (verses.isEmpty && introductionAsyncValue is! AsyncData) {
                // Show loading or error for introduction if verses are empty
                return introductionAsyncValue.when(
                  data: (intro) => const Center(
                    child: Text(
                      'No verses found, but introduction loaded.', // Or handle appropriately
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(
                    child: Text(
                      'No verses found and failed to load introduction.\nError: $e',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }

              // Display introduction and verses using ScrollablePositionedList
              return ScrollablePositionedList.builder(
                padding: const EdgeInsets.all(8.0),
                itemScrollController: itemScrollController, // Assign controller
                itemPositionsListener: itemPositionsListener, // Assign listener
                // Add 1 to item count for the introduction card
                itemCount: verses.length + 1,
                itemBuilder: (context, index) {
                  // Index 0 is the introduction card
                  if (index == 0) {
                    return SurahIntroductionCard(
                      introductionAsync:
                          introductionAsyncValue, // Pass derived value
                      // Get surah name from list provider or fallback
                      surahName: surahListAsync.when(
                        data: (list) {
                          final info = list.firstWhere(
                            (s) => s.number == widget.surahNumber,
                            orElse: () => SurahInfo(
                              number: widget.surahNumber,
                              name: 'Surah ${widget.surahNumber}',
                              englishName: widget.surahName ??
                                  'Surah ${widget.surahNumber}',
                              englishNameTranslation: '',
                              revelationType: '',
                              numberOfAyahs: 0,
                            ),
                          );
                          return info.englishName;
                        },
                        loading: () =>
                            widget.surahName ?? 'Surah ${widget.surahNumber}',
                        error: (_, __) =>
                            widget.surahName ?? 'Surah ${widget.surahNumber}',
                      ),
                    );
                  }

                  // Subsequent indices are verse tiles (adjust index by -1)
                  final verseIndex = index - 1;
                  if (verseIndex < verses.length) {
                    final Verse verse = verses[verseIndex];
                    // Use the dedicated VerseTile widget
                    return VerseTile(
                      verse: verse,
                      surahNumber: widget.surahNumber,
                    );
                  }
                  // Return an empty widget instead of null
                  return const SizedBox.shrink();
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) {
              print(
                'Error loading Surah ${widget.surahNumber} details UI: $error\n$stackTrace',
              );
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Failed to load verses for Surah ${widget.surahNumber}.\nError: $error',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }, // Close error builder
          ), // Close surahDetailsAsync.when
        ],
      ),
    );
  }
}
