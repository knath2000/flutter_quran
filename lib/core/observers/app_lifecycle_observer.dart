import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/core/audio/audio_playback_notifier.dart';
import 'package:quran_flutter/core/audio/playback_state.dart';
import 'package:quran_flutter/features/gamification/application/user_progress_provider.dart';
import 'package:quran_flutter/features/settings/application/settings_providers.dart';
import 'package:quran_flutter/features/quran_reader/application/providers/surah_details_provider.dart';
import 'package:quran_flutter/core/audio/audio_player_service.dart';
import 'dart:async'; // For Future.microtask
import 'package:quran_flutter/core/models/verse.dart'; // Import Verse model

/// A widget that observes application-level state changes without building UI.
/// Used here to listen for audio completion and trigger game logic / autoplay.
class AppLifecycleObserver extends ConsumerStatefulWidget {
  final Widget child;
  const AppLifecycleObserver({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleObserver> createState() =>
      _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends ConsumerState<AppLifecycleObserver> {
  // Flag to prevent processing multiple completion events for the same verse trigger
  bool _isProcessingCompletion = false;
  PlayingVerseIdentifier?
  _lastProcessedVerseId; // Track the ID we are processing

  @override
  Widget build(BuildContext context) {
    ref.listen<AudioPlaybackState>(audioPlaybackStateProvider, (
      previous,
      next,
    ) {
      // --- Reset Autoplay Lock ---
      // Reset the flag if the state changes to something other than completed,
      // OR if it's completed but for a DIFFERENT verse than the one we just processed.
      if (_isProcessingCompletion) {
        bool shouldReset = false;
        if (next.status != PlaybackStatus.completed &&
            next.status != PlaybackStatus.loading) {
          shouldReset = true;
          print(
            "AppObserver: Resetting completion flag (state is ${next.status})",
          );
        } else if (next.status == PlaybackStatus.completed &&
            next.playingVerseId != null &&
            next.playingVerseId != _lastProcessedVerseId) {
          print(
            "AppObserver: Resetting completion flag (new completed ID ${next.playingVerseId} != processed ID $_lastProcessedVerseId)",
          );
          shouldReset = true;
        }

        if (shouldReset) {
          _isProcessingCompletion = false;
          _lastProcessedVerseId = null;
        }
      }

      // --- Handle Completion Event & Trigger Actions ---
      // Check if:
      // 1. The state *just* transitioned to completed.
      // 2. The *previous* state had a valid verse ID.
      // 3. We aren't *already* processing a completion/autoplay trigger.
      if (!_isProcessingCompletion &&
          next.status == PlaybackStatus.completed &&
          previous?.playingVerseId != null) {
        // Set flag immediately
        _isProcessingCompletion = true;
        final completedVerseId = previous!.playingVerseId!;
        _lastProcessedVerseId =
            completedVerseId; // Track which completion we're handling

        print(
          'AppObserver: Verse completed - $completedVerseId. Triggering actions.',
        );

        // --- Trigger Game Logic (asynchronously) ---
        Future.microtask(() {
          final userProgressNotifier = ref.read(userProgressProvider.notifier);
          userProgressNotifier.addPoints(1);
          userProgressNotifier.addBadge('first_verse');
          userProgressNotifier.markVerseCompleted(
            completedVerseId.surahNumber,
            completedVerseId.verseNumber,
          );
        });

        // --- Handle Autoplay ---
        final isAutoplayEnabled = ref.read(autoplayEnabledProvider);
        print('AppObserver: Autoplay enabled: $isAutoplayEnabled');

        if (isAutoplayEnabled) {
          final surahDetailsNotifier = ref.read(
            surahDetailsProvider(completedVerseId.surahNumber).notifier,
          );
          // Read the current state which is AsyncValue<(List<Verse>, String)>
          final currentState = ref.read(
            surahDetailsProvider(completedVerseId.surahNumber),
          );
          List<Verse>? cachedVerses;
          if (currentState is AsyncData<(List<Verse>, String)>) {
            cachedVerses =
                currentState.value.$1; // Access verses from the record
          }
          // final cachedVerses = surahDetailsNotifier.getCachedSurah(); // Old method removed

          if (cachedVerses != null) {
            final totalVerses = cachedVerses.length;
            final nextVerseNumber = completedVerseId.verseNumber + 1;

            print(
              'AppObserver: Checking next verse: $nextVerseNumber / $totalVerses',
            );

            if (nextVerseNumber <= totalVerses) {
              final nextVerse = cachedVerses[nextVerseNumber - 1];
              final nextUrl = nextVerse.audioUrl;

              if (nextUrl != null && nextUrl.isNotEmpty) {
                final nextVerseId = PlayingVerseIdentifier(
                  completedVerseId.surahNumber,
                  nextVerseNumber,
                );
                _lastProcessedVerseId =
                    nextVerseId; // Update expected ID for reset logic

                print(
                  'AppObserver: Autoplaying verse $nextVerseNumber ($nextVerseId)',
                );
                // Call playVerse directly (no microtask)
                ref
                    .read(audioPlayerServiceProvider)
                    .playVerse(
                      nextUrl,
                      completedVerseId.surahNumber,
                      nextVerseNumber,
                    );
                // Flag remains true until state changes appropriately
              } else {
                print(
                  'AppObserver: Next verse ($nextVerseNumber) has no audio URL.',
                );
                _isProcessingCompletion =
                    false; // Reset flag if next fails immediately
                _lastProcessedVerseId = null;
              }
            } else {
              print(
                'AppObserver: End of Surah ${completedVerseId.surahNumber} reached.',
              );
              _isProcessingCompletion = false; // Reset flag at end of surah
              _lastProcessedVerseId = null;
            }
          } else {
            print(
              'AppObserver: Could not find cached verses for Surah ${completedVerseId.surahNumber} to autoplay.',
            );
            _isProcessingCompletion = false; // Reset flag if cache fails
            _lastProcessedVerseId = null;
          }
        } else {
          // If autoplay is disabled, reset the flag immediately
          _isProcessingCompletion = false;
          _lastProcessedVerseId = null;
        }
      }
    });

    return widget.child;
  }
}
