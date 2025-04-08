import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/core/models/surah_info.dart';
import 'package:quran_flutter/features/quran_reader/data/repositories/quran_repository.dart';

// FutureProvider to fetch the list of Surahs
final surahListProvider = FutureProvider<List<SurahInfo>>((ref) async {
  // Watch the repository provider
  final repository = ref.watch(quranRepositoryProvider);
  // Call the repository method to get the data
  try {
    final surahs = await repository.getSurahList();
    // Optional: Sort surahs by number if the API doesn't guarantee order
    surahs.sort((a, b) => a.number.compareTo(b.number));
    return surahs;
  } catch (e) {
    // Handle errors and potentially log them
    print('Error fetching Surah list in provider: $e');
    // Rethrow to allow UI to handle the error state
    rethrow;
  }
});
