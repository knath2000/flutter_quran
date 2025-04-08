# Plan: Use Local CSV for Arabic Text (Web/macOS)

**Goal:** Modify the app (macOS & Web versions) to load and display Arabic verse text by parsing and processing the provided `assets/wbw.csv` file instead of relying solely on API calls. iOS will continue to use the existing API-based method for Arabic text.

**Approach:** Pre-process the CSV into a queryable JSON format offline. Load this JSON as an asset on Web/macOS. Use a platform-specific provider to determine whether to fetch Arabic text from the JSON asset (Web/macOS) or rely on the existing data source (iOS).

---

## Phase 1: Data Pre-processing (Offline Developer Task)

1.  **Create Pre-processing Script:**
    *   **Location:** `tool/process_quran_csv.dart` (create if needed).
    *   **Input:** `assets/wbw.csv`.
    *   **Dependencies:** Add `package:csv` to `dev_dependencies` in `pubspec.yaml`.
    *   **Logic:**
        *   Read the CSV file row by row.
        *   Group rows by `Sura_No` and `Verse_No`.
        *   For each unique Surah/Verse combination, concatenate the `Word` column values in `Word_No` order to reconstruct the full Arabic verse text.
        *   Handle potential punctuation from `Punctuation_Mark` column if necessary (e.g., append it to the preceding word).
        *   Structure the output as a nested map: `Map<String, Map<String, String>>` (Surah Number -> Verse Number -> Verse Text). Using String keys simplifies JSON handling.
    *   **Output:** `assets/data/quran_arabic_text.json`. Create the `assets/data/` directory.
    *   **Execution:** Run manually via `dart run tool/process_quran_csv.dart`. Commit the generated JSON file to the repository.

## Phase 2: App Implementation

1.  **Asset Declaration:**
    *   Add `assets/data/quran_arabic_text.json` to the `assets:` section in `pubspec.yaml`.

2.  **JSON Data Service:**
    *   Create file: `lib/core/data/json_quran_text_service.dart`
    *   Define class `JsonQuranTextService`.
    *   Implement `Future<void> initialize()`:
        *   Loads `assets/data/quran_arabic_text.json` using `rootBundle`.
        *   Parses the JSON string using `jsonDecode`.
        *   Stores the parsed data in a private `Map<String, Map<String, String>>? _quranData`.
        *   Includes error handling for file loading and parsing.
    *   Implement `Future<String?> getArabicVerseText(int surah, int verse)`:
        *   Ensures `initialize()` has completed.
        *   Looks up the text using `_quranData?[surah.toString()]?[verse.toString()]`.
        *   Returns the text or `null` if not found.

3.  **Platform-Specific Provider:**
    *   Create file (or add to existing providers file like `lib/core/providers/app_providers.dart`):
    *   Define `quranTextSourceProvider`:
        ```dart
        import 'package:flutter/foundation.dart' show kIsWeb;
        import 'dart:io' show Platform;
        import 'package:flutter_riverpod/flutter_riverpod.dart';
        import 'package:quran_flutter/core/data/json_quran_text_service.dart'; // Adjust import

        final quranTextSourceProvider = Provider<JsonQuranTextService?>((ref) {
          if (kIsWeb || Platform.isMacOS) {
            print("Using JSON data source for Quran text.");
            return JsonQuranTextService();
          } else {
            print("Not using JSON data source for Quran text on this platform.");
            return null; // iOS and others get null
          }
        });
        ```
    *   Define `jsonDataSourceInitializerProvider`:
        ```dart
        final jsonDataSourceInitializerProvider = FutureProvider<void>((ref) async {
           final source = ref.watch(quranTextSourceProvider);
           if (source != null) { // Only initialize if we have the JSON source
              print("Initializing JSON Quran text data source...");
              await source.initialize();
              print("JSON Quran text data source initialized.");
           }
        });
        ```

4.  **Initialize JSON Data:**
    *   Modify `main.dart`: Add a `ProviderObserver` (e.g., `AppInitializerObserver`) to the `ProviderScope`.
    *   In the observer's `didAddProvider`, check if the provider is `jsonDataSourceInitializerProvider` and call `container.read(jsonDataSourceInitializerProvider)` to trigger the initialization early for Web/macOS.

5.  **Update `VerseTile.dart`:**
    *   Import necessary providers.
    *   In the `build` method:
        *   Read the platform source: `final jsonSource = ref.watch(quranTextSourceProvider);`.
        *   Locate the Arabic `Text` widget (currently displaying `widget.verse.text`).
        *   **Conditional Logic:**
            *   **If `jsonSource != null` (Web/macOS):**
                *   Create or use a `FutureProvider.family` (e.g., `arabicJsonTextProvider`) that takes `PlayingVerseIdentifier` and calls `jsonSource.getArabicVerseText()`.
                *   Watch this provider: `final arabicTextAsync = ref.watch(arabicJsonTextProvider(currentVerseId));`.
                *   Replace the existing Arabic `Text` widget with `arabicTextAsync.when(...)`:
                    *   `data:` -> Display the fetched text from JSON.
                    *   `loading:` -> Display a small loading indicator (e.g., `SizedBox` with `CircularProgressIndicator`).
                    *   `error:` -> Display an error message.
            *   **Else (`jsonSource == null`, iOS/Other):**
                *   Keep the existing `Text(widget.verse.text, ...)` widget, assuming `widget.verse.text` contains the Arabic text fetched via the primary API call in `surahDetailsProvider`.

6.  **Verification:**
    *   Run on macOS/Web: Verify Arabic text loads from JSON (check logs, visual confirmation).
    *   Run on iOS: Verify Arabic text still loads correctly from the original source (`widget.verse.text` via API).
    *   Check performance on Web/macOS, especially initial load time and scrolling smoothness in `QuranReaderScreen`.

---

This plan outlines the steps to integrate the local CSV data for Arabic text display specifically on Web and macOS, while maintaining the existing API-based approach for iOS.