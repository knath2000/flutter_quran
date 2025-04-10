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
  // Use correct type now that VerseAdapter is registered
  final Box<List<Verse>> _verseCacheBox;

  QuranRepository(this._apiDataSource)
      : _verseCacheBox = Hive.box<List<Verse>>('quranVerseCache');

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
    // 1. Check cache first (Hive handles deserialization via adapter)
    final List<Verse>? cachedVerses = _verseCacheBox.get(surahNumber);
    if (cachedVerses != null) {
      print('Cache hit for Surah $surahNumber verses.');
      return cachedVerses;
    }

    // 2. If cache miss or error, fetch from API
    print('Cache miss for Surah $surahNumber verses. Fetching from API...');
    try {
      final verses = await _apiDataSource.getSurahDetails(surahNumber);

      // 3. Save fetched verses to cache (Hive handles serialization via adapter)
      await _verseCacheBox.put(surahNumber, verses);
      print('Saved Surah $surahNumber verses to cache.');

      return verses;
    } catch (e) {
      print(
          'Error fetching/caching Surah details for $surahNumber from API: $e');
      rethrow;
    }
  }
}
