import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/core/audio/audio_player_service.dart';
import 'package:quran_flutter/core/audio/audio_playback_notifier.dart'; // Import playback state
import 'package:quran_flutter/core/audio/playback_state.dart'; // Import playback status enum
import 'package:quran_flutter/core/models/verse.dart';
import 'package:quran_flutter/features/quran_reader/application/providers/surah_details_provider.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surahName ?? 'Surah ${widget.surahNumber}'),
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
          ),
          // Use the AsyncValue directly from the StateNotifierProvider
          surahDetailsAsync.when(
            data: (verses) {
              if (verses.isEmpty) {
                return const Center(
                  child: Text(
                    'No verses found for this Surah.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              // Data prep for autoplay removed (handled by service)

              // Display verses in a list
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: verses.length, // Use direct length
                itemBuilder: (context, index) {
                  final Verse verse = verses[index];
                  // Use the dedicated VerseTile widget
                  return VerseTile(
                    verse: verse,
                    surahNumber: widget.surahNumber,
                    // Parameters removed in previous step
                  );
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
            },
          ),
        ],
      ),
    );
  }
}
