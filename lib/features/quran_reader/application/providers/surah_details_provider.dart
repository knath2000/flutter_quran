import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/core/models/verse.dart';
import 'package:quran_flutter/features/quran_reader/data/repositories/quran_repository.dart';
import 'package:quran_flutter/core/services/gemini_surah_service.dart'; // Import the service

// Define the provider for GeminiSurahService
final geminiSurahServiceProvider = Provider<GeminiSurahService>((ref) {
  return GeminiSurahService();
});

// StateNotifier for managing Surah details fetching and caching
class SurahDetailsNotifier extends StateNotifier<AsyncValue<List<Verse>>> {
  final Ref _ref; // Keep ref to read other providers
  final int surahNumber; // Store the surah number this notifier is for

  // Cache for the fetched verses
  List<Verse>? _cachedVerses;
  // Prevent concurrent fetches
  Completer<void>? _fetchCompleter;

  SurahDetailsNotifier(this._ref, this.surahNumber)
    : super(const AsyncValue.loading()) {
    // Optionally fetch immediately upon creation, or require explicit call
    // fetchSurah(); // Let's require explicit call from UI
  }

  Future<void> fetchSurah() async {
    // If already fetching, wait for the existing fetch to complete
    if (_fetchCompleter != null && !_fetchCompleter!.isCompleted) {
      return _fetchCompleter!.future;
    }
    // If already loaded successfully, do nothing
    if (state is AsyncData && _cachedVerses != null) {
      return;
    }

    // Start a new fetch
    _fetchCompleter = Completer<void>();
    state = const AsyncValue.loading(); // Set loading state

    try {
      final repository = _ref.read(quranRepositoryProvider);
      final verses = await repository.getSurahDetails(surahNumber);

      // Generate introductions using Gemini
      final geminiService = _ref.read(
        geminiSurahServiceProvider,
      ); // Use _ref and ensure provider is defined
      for (var verse in verses) {
        verse.introduction = await geminiService.generateSurahIntroduction(
          surahNumber,
        ); // Add or update introduction field
      }

      // Removed duplicate block
      _cachedVerses = verses; // Store in cache
      state = AsyncValue.data(verses); // Set data state
      print(
        'Successfully fetched, cached Surah $surahNumber, and generated introductions',
      );

      _fetchCompleter!.complete(); // Mark fetch as complete
    } catch (e, stackTrace) {
      print('Error in Surah details for $surahNumber: $e');
      state = AsyncValue.error(e, stackTrace);
      _cachedVerses = null;
      _fetchCompleter!.completeError(e, stackTrace);
    }
  }

  // Method to get cached data if available for the correct surah
  List<Verse>? getCachedSurah() {
    // Ensure the current state is data before returning cache
    if (state is AsyncData<List<Verse>>) {
      return _cachedVerses;
    }
    return null;
  }

  // Optional: Method to force refresh
  Future<void> refresh() async {
    _cachedVerses = null; // Clear cache
    _fetchCompleter = null; // Allow new fetch
    await fetchSurah();
  }
}

// StateNotifierProvider.family to create instances based on surahNumber
final surahDetailsProvider = StateNotifierProvider.family<
  SurahDetailsNotifier,
  AsyncValue<List<Verse>>,
  int
>((ref, surahNumber) {
  return SurahDetailsNotifier(ref, surahNumber);
});
