import 'dart:async'; // Import for Completer
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle; // For loading assets
// Removed unused IQuranTextDataSource interface for now to simplify

class JsonQuranTextService {
  // Cache for the loaded Quran data
  Map<String, Map<String, String>>? _quranData;
  bool _isInitialized = false;
  Completer<void>?
  _initCompleter; // Use Completer to manage initialization state

  // Singleton pattern might be useful here, but let's use provider scope for now.
  // static final JsonQuranTextService _instance = JsonQuranTextService._internal();
  // factory JsonQuranTextService() => _instance;
  // JsonQuranTextService._internal();

  Future<void> initialize() async {
    // If initialization is already complete, return immediately.
    if (_isInitialized) return;
    // If initialization is in progress, wait for it to complete.
    if (_initCompleter != null) return _initCompleter!.future;

    // Start initialization
    _initCompleter = Completer<void>();
    print("JsonQuranTextService: Starting initialization...");

    try {
      print("JsonQuranTextService: Loading Quran text from JSON asset...");
      final jsonString = await rootBundle.loadString(
        'assets/data/quran_arabic_text.json',
      );
      // Use compute function for large JSON parsing to avoid blocking main thread
      // final Map<String, dynamic> jsonData = await compute(jsonDecode, jsonString); // Requires foundation import
      // For simplicity now, parse directly:
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      // Convert keys back if needed, assuming they are strings in JSON
      _quranData = jsonData.map(
        (surahKey, verseMap) =>
            MapEntry(surahKey, Map<String, String>.from(verseMap as Map)),
      );

      _isInitialized = true; // Mark as initialized *before* completing
      print("JsonQuranTextService: Quran text loaded and parsed successfully.");
      _initCompleter!.complete(); // Complete the future successfully
    } catch (e, s) {
      print("JsonQuranTextService: Error loading/parsing JSON asset: $e");
      print(s); // Print stack trace for debugging
      _quranData = null; // Ensure data is null on error
      _isInitialized = false; // Ensure it's marked as not initialized on error
      _initCompleter!.completeError(e, s); // Complete the future with an error
      // Rethrow to allow FutureProvider to catch it? Or handle gracefully?
      // Let's rethrow so the FutureProvider enters error state.
      rethrow;
    } finally {
      // Reset completer whether it succeeded or failed, allowing retry if needed
      // _initCompleter = null; // Let's keep it completed/errored
    }
  }

  Future<String?> getArabicVerseText(int surahNumber, int verseNumber) async {
    // Always await initialization. If already done, it returns immediately.
    // If in progress, it waits. If not started, it starts and waits.
    try {
      await initialize();
    } catch (e) {
      print(
        "JsonQuranTextService: Initialization failed during getArabicVerseText. Error: $e",
      );
      return null; // Return null if initialization failed
    }

    if (_quranData == null) {
      print(
        "JsonQuranTextService: Quran data is null after initialization attempt.",
      );
      return null;
    }

    final surahKey = surahNumber.toString();
    final verseKey = verseNumber.toString();

    if (_quranData!.containsKey(surahKey)) {
      if (_quranData![surahKey]!.containsKey(verseKey)) {
        return _quranData![surahKey]![verseKey];
      } else {
        print(
          "JsonQuranTextService: Verse $verseKey not found in Surah $surahKey.",
        );
        return null;
      }
    } else {
      print("JsonQuranTextService: Surah $surahKey not found.");
      return null;
    }
  }
}
