import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart'; // Import Hive
import 'package:quran_flutter/core/api/quran_api_data_source.dart';
import 'package:quran_flutter/core/models/surah_info.dart';
import 'package:quran_flutter/core/models/verse.dart';

// Provider for the repository implementation
// We provide the implementation class but type hint with the interface
final quranRepositoryProvider = Provider<IQuranRepository>((ref) {
  final apiDataSource = ref.watch(quranApiDataSourceProvider);
  // Add other data sources (e.g., local cache) here if needed
  return QuranRepository(apiDataSource);
});

// Abstract class (interface) for the repository - good practice for testability/swappability
abstract class IQuranRepository {
  Future<List<SurahInfo>> getSurahList();
  Future<List<Verse>> getSurahDetails(int surahNumber);
}

class QuranRepository implements IQuranRepository {
  final QuranApiDataSource _apiDataSource;
  final Box<List<dynamic>>
      _verseCacheBox; // Use List<dynamic> if adapter not ready

  QuranRepository(this._apiDataSource)
      : _verseCacheBox = Hive.box<List<dynamic>>('quranVerseCache');

  @override
  Future<List<SurahInfo>> getSurahList() async {
    // For now, just fetch directly from the API data source.
    // Later, logic for caching or combining data sources could be added here.
    try {
      // Consider adding caching logic here in the future
      return await _apiDataSource.getSurahList();
    } catch (e) {
      // Handle or rethrow repository-level errors
      print('Error in QuranRepository getting Surah list: $e');
      rethrow; // Rethrow the exception to be handled by the provider/UI
    }
  }

  @override
  Future<List<Verse>> getSurahDetails(int surahNumber) async {
    // 1. Check cache first
    final cachedData = _verseCacheBox.get(surahNumber);
    if (cachedData != null) {
      print('Cache hit for Surah $surahNumber verses.');
      // TODO: If VerseAdapter is registered and working, this box should be Box<List<Verse>>
      // and casting won't be needed or will be simpler.
      // For now, assume dynamic list needs parsing if adapter isn't used for storage.
      try {
        // This assumes cachedData is List<Map<String, dynamic>> if not stored as List<Verse>
        // If stored as List<Verse> directly (requires adapter), just cast: return cachedData as List<Verse>;
        return cachedData
            .map((dynamic item) => Verse.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print(
            'Error parsing cached verse data for Surah $surahNumber: $e. Fetching from API.');
        // Fall through to fetch from API if cache parsing fails
      }
    }

    // 2. If cache miss or error, fetch from API
    print('Cache miss for Surah $surahNumber verses. Fetching from API...');
    try {
      final verses = await _apiDataSource.getSurahDetails(surahNumber);

      // 3. Save to cache before returning
      // TODO: If VerseAdapter is working, store `verses` directly.
      // Otherwise, convert to List<Map<String, dynamic>> if needed for storage.
      // For simplicity now, assuming we can store List<Verse> if adapter is set up,
      // otherwise store raw JSON-like structure if needed. Let's store verses directly for now.
      // Use put instead of add, with surahNumber as the key
      await _verseCacheBox.put(surahNumber, verses); // Store the List<Verse>
      print('Saved Surah $surahNumber verses to cache.');

      return verses;
    } catch (e) {
      print(
          'Error fetching/caching Surah details for $surahNumber from API: $e');
      rethrow;
    }
  }
}
