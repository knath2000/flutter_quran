import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/core/audio/audio_player_service.dart';
import 'package:quran_flutter/core/audio/audio_playback_notifier.dart'; // Import playback state
import 'package:quran_flutter/core/audio/playback_state.dart'; // Import playback status enum
import 'package:quran_flutter/core/models/surah_info.dart'; // Import SurahInfo
import 'package:quran_flutter/core/models/verse.dart';
import 'package:quran_flutter/features/quran_reader/application/providers/surah_details_provider.dart';
import 'package:quran_flutter/features/quran_reader/application/providers/surah_list_provider.dart';
import 'package:quran_flutter/features/quran_reader/application/providers/surah_introduction_provider.dart'; // Import new provider
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
  @override
  void initState() {
    super.initState();
    // Fetch surah details when the screen initializes
    // Use ref.read as we only need the notifier instance, not rebuild on change
    // Use addPostFrameCallback to ensure context/ref is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Check if widget is still mounted
        ref
            .read(surahDetailsProvider(widget.surahNumber).notifier)
            .fetchSurah();
      }
    });
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

              // Display introduction and verses in a single scrollable list
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
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
                  return null; // Should not happen if itemCount is correct
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
