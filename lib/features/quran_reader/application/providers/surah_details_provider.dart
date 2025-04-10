import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart'; // Import Hive
import 'package:quran_flutter/core/models/verse.dart';
import 'package:quran_flutter/features/quran_reader/data/repositories/quran_repository.dart';
import 'package:quran_flutter/core/services/gemini_surah_service.dart';

// Define the provider for GeminiSurahService
final geminiSurahServiceProvider = Provider<GeminiSurahService>((ref) {
  return GeminiSurahService();
});

// StateNotifier for managing Surah details fetching and caching
// Define the combined state type using a record
typedef SurahDetailsState = AsyncValue<(List<Verse>, String)>;

class SurahDetailsNotifier extends StateNotifier<SurahDetailsState> {
  final Ref _ref; // Keep ref to read other providers
  final int surahNumber; // Store the surah number this notifier is for

  // Cache for the fetched verses
  // Cache for the combined state (optional, state itself holds the data)
  // (List<Verse>, String)? _cachedDetails;
  // Prevent concurrent fetches
  Completer<void>? _fetchCompleter;

  final Box<String> _introCacheBox; // Add intro cache box

  SurahDetailsNotifier(this._ref, this.surahNumber)
      : _introCacheBox =
            Hive.box<String>('surahIntroductionCache'), // Initialize box first
        super(const AsyncValue.loading()) {
    // Then call super
    // Optionally fetch immediately upon creation, or require explicit call
    // fetchSurah(); // Let's require explicit call from UI
  }

  Future<void> fetchSurah() async {
    // If already fetching, wait for the existing fetch to complete
    if (_fetchCompleter != null && !_fetchCompleter!.isCompleted) {
      return _fetchCompleter!.future;
    }
    // If already loaded successfully, do nothing
    // Check if state is already loaded data
    if (state is AsyncData<(List<Verse>, String)>) {
      return;
    }

    // Start a new fetch
    _fetchCompleter = Completer<void>();
    state = const AsyncValue.loading(); // Set loading state

    try {
      final repository = _ref.read(quranRepositoryProvider);
      // Fetch verses and introduction concurrently or sequentially
      final verses = await repository.getSurahDetails(surahNumber);

      // Check intro cache first
      String? cachedIntro = _introCacheBox.get(surahNumber);
      String introduction;

      if (cachedIntro != null) {
        print('Cache hit for Surah $surahNumber introduction.');
        introduction = cachedIntro;
      } else {
        print(
            'Cache miss for Surah $surahNumber introduction. Fetching from Gemini...');
        introduction = 'Introduction not available.'; // Default value
        try {
          final geminiService = _ref.read(geminiSurahServiceProvider);
          introduction =
              await geminiService.generateSurahIntroduction(surahNumber);
          print('Generated Introduction for Surah $surahNumber: $introduction');
          // Save fetched intro to cache
          await _introCacheBox.put(surahNumber, introduction);
          print('Saved Surah $surahNumber introduction to cache.');
        } catch (geminiError) {
          print(
              'Error generating/caching introduction for Surah $surahNumber: $geminiError');
          // Use the default introduction string on error
        }
      }

      // Set the combined state
      state = AsyncValue.data((verses, introduction));
      print('Successfully fetched Surah $surahNumber verses and introduction.');

      _fetchCompleter!.complete(); // Mark fetch as complete
    } catch (e, stackTrace) {
      print('Error fetching Surah details for $surahNumber: $e');
      state = AsyncValue.error(
        e,
        stackTrace,
      ); // Set error state for the combined type
      // _cachedDetails = null; // Clear cache if using one
      _fetchCompleter!.completeError(e, stackTrace);
    }
  }

  // Removed getCachedSurah as state now holds combined data

  // Optional: Method to force refresh
  Future<void> refresh() async {
    // _cachedDetails = null; // Clear cache if using one
    _fetchCompleter = null; // Allow new fetch
    await fetchSurah();
  }
}

// StateNotifierProvider.family to create instances based on surahNumber
final surahDetailsProvider =
    StateNotifierProvider.family<SurahDetailsNotifier, SurahDetailsState, int>((
  ref,
  surahNumber,
) {
  return SurahDetailsNotifier(ref, surahNumber);
});
