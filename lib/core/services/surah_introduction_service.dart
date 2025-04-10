import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the service
final surahIntroductionServiceProvider = Provider<SurahIntroductionService>((
  ref,
) {
  return SurahIntroductionService();
});

class SurahIntroductionService {
  // Use late final to load data once upon first access
  late final Future<Map<String, String>> _introductionsFuture =
      _loadIntroductions();
  Map<String, String>? _introductions; // Cache after loading

  SurahIntroductionService() {
    // Trigger loading immediately but don't block constructor
    _initialize();
  }

  Future<void> _initialize() async {
    // Ensure data is loaded and cached
    _introductions ??= await _introductionsFuture;
    print("Surah Introduction Service Initialized.");
  }

  Future<Map<String, String>> _loadIntroductions() async {
    try {
      print("Loading surah introductions from JSON...");
      final String jsonString = await rootBundle.loadString(
        'assets/data/surah_introductions.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      // Ensure values are strings
      final Map<String, String> introductions = jsonMap.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      print("Surah introductions loaded successfully.");
      return introductions;
    } catch (e) {
      print('Error loading surah introductions: $e');
      // Return empty map on error to prevent future load attempts
      return {};
    }
  }

  /// Fetches the introduction for a specific Surah number.
  /// Returns null if not found or if loading failed.
  Future<String?> getIntroduction(int surahNumber) async {
    // Ensure data is loaded before attempting access
    _introductions ??= await _introductionsFuture;
    final String surahKey = surahNumber.toString();
    return _introductions?[surahKey];
  }
}
