import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/core/api/api_client.dart';
import 'package:quran_flutter/core/models/surah_info.dart';
import 'package:quran_flutter/core/models/verse.dart';

// Provider for the data source
final quranApiDataSourceProvider = Provider<QuranApiDataSource>((ref) {
  final dio = ref.watch(apiClientProvider);
  return QuranApiDataSource(dio);
});

class QuranApiDataSource {
  final Dio _dio;

  QuranApiDataSource(this._dio);

  /// Fetches the list of all Surahs from the API.
  Future<List<SurahInfo>> getSurahList() async {
    try {
      // Example endpoint for alquran.cloud API to get metadata including Surah list
      final response = await _dio.get('/meta');

      if (response.statusCode == 200 && response.data != null) {
        // Adjust parsing based on the actual API response structure
        // Assuming the response structure is like: { data: { surahs: { references: [ {...}, ... ] } } }
        // Ensure data and nested keys are not null before accessing
        final Map<String, dynamic>? data =
            response.data as Map<String, dynamic>?;
        final List<dynamic>? surahRefs =
            data?['data']?['surahs']?['references'] as List<dynamic>?;

        if (surahRefs == null) {
          throw Exception(
            'Failed to parse Surah list: Invalid API response structure.',
          );
        }

        final List<SurahInfo> surahs =
            surahRefs
                .map((json) => SurahInfo.fromJson(json as Map<String, dynamic>))
                .toList();
        return surahs;
      } else {
        // Handle non-200 status codes or null data
        throw Exception(
          'Failed to load Surah list: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Handle Dio specific errors (network, timeout, etc.)
      // Log the error or rethrow a more specific exception
      print('DioError fetching Surah list: $e');
      throw Exception('Failed to load Surah list: ${e.message}');
    } catch (e) {
      // Handle other potential errors during parsing etc.
      print('Error fetching Surah list: $e');
      throw Exception('Failed to load Surah list');
    }
  }

  /// Fetches the details for a specific Surah, including all its verses
  /// with Arabic text, translation, and audio URLs.
  ///
  /// Note: This example assumes fetching multiple editions and combining them.
  /// Adjust based on the chosen API's capabilities.
  Future<List<Verse>> getSurahDetails(
    int surahNumber, {
    String arabicEdition = 'quran-uthmani', // Default Arabic edition
    String translationEdition = 'en.sahih', // Example English translation
    String audioEdition = 'ar.alafasy', // Example Audio edition
    String transliterationEdition =
        'en.transliteration', // Default transliteration
  }) async {
    try {
      // Construct the endpoint to fetch multiple editions for the surah
      final endpoint =
          '/surah/$surahNumber/editions/$arabicEdition,$translationEdition,$audioEdition,$transliterationEdition';
      final response = await _dio.get(endpoint);

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic>? data =
            response.data as Map<String, dynamic>?;
        final List<dynamic>? editionsData = data?['data'] as List<dynamic>?;

        // Expecting 4 editions now: Arabic, Translation, Audio, Transliteration
        if (editionsData == null || editionsData.length < 4) {
          throw Exception(
            'Failed to parse Surah details: Missing required editions (Arabic, Translation, Audio, Transliteration) in response.',
          );
        }

        // Find the data for each edition (assuming order might vary)
        final arabicData = editionsData.firstWhere(
          (e) => e['edition']['identifier'] == arabicEdition,
          orElse: () => null,
        );
        final translationData = editionsData.firstWhere(
          (e) => e['edition']['identifier'] == translationEdition,
          orElse: () => null,
        );
        final audioData = editionsData.firstWhere(
          (e) => e['edition']['identifier'] == audioEdition,
          orElse: () => null,
        );
        final transliterationData = editionsData.firstWhere(
          (e) => e['edition']['identifier'] == transliterationEdition,
          orElse: () => null,
        );

        if (arabicData == null || arabicData['ayahs'] == null) {
          throw Exception(
            'Failed to parse Surah details: Arabic text edition missing or invalid.',
          );
        }

        final List<dynamic> arabicAyahs = arabicData['ayahs'];
        final List<dynamic>? translationAyahs = translationData?['ayahs'];
        final List<dynamic>? audioAyahs = audioData?['ayahs'];
        final List<dynamic>? transliterationAyahs =
            transliterationData?['ayahs'];

        List<Verse> verses = [];
        for (int i = 0; i < arabicAyahs.length; i++) {
          final arabicJson = arabicAyahs[i] as Map<String, dynamic>;
          // Find corresponding translation and audio ayah data (match by numberInSurah)
          final int currentNumberInSurah =
              arabicJson['numberInSurah'] as int? ?? 0;
          final translationJson = translationAyahs?.firstWhere(
            (t) => t['numberInSurah'] == currentNumberInSurah,
            orElse: () => null,
          );
          final audioJson = audioAyahs?.firstWhere(
            (a) => a['numberInSurah'] == currentNumberInSurah,
            orElse: () => null,
          );
          final transliterationJson = transliterationAyahs?.firstWhere(
            (tr) => tr['numberInSurah'] == currentNumberInSurah,
            orElse: () => null,
          );

          verses.add(
            Verse.fromJson(
              arabicJson,
              // Pass overrides from other editions
              audioUrlOverride: audioJson?['audio'] as String?,
              translationTextOverride: translationJson?['text'] as String?,
              transliterationTextOverride:
                  transliterationJson?['text'] as String?,
            ),
          );
        }
        return verses;
      } else {
        throw Exception(
          'Failed to load Surah details: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('DioError fetching Surah details for $surahNumber: $e');
      throw Exception('Failed to load Surah details: ${e.message}');
    } catch (e) {
      print('Error fetching Surah details for $surahNumber: $e');
      throw Exception('Failed to load Surah details');
    }
  }
}
