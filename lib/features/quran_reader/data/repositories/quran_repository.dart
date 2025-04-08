import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/core/api/quran_api_data_source.dart';
import 'package:quran_flutter/core/models/surah_info.dart';
import 'package:quran_flutter/core/models/verse.dart'; // Import Verse model

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
  // Add other data sources here (e.g., local cache)

  QuranRepository(this._apiDataSource);

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
    // For now, fetch directly from the API data source.
    // Add caching logic here later if needed.
    try {
      // TODO: Potentially pass specific edition identifiers if needed
      return await _apiDataSource.getSurahDetails(surahNumber);
    } catch (e) {
      print(
        'Error in QuranRepository getting Surah details for $surahNumber: $e',
      );
      rethrow;
    }
  }
}
