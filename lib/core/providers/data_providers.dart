import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/core/data/json_quran_text_service.dart';

/// Provider that returns an instance of [JsonQuranTextService] on supported platforms (Web, macOS),
/// and null otherwise.
final quranTextSourceProvider = Provider<JsonQuranTextService?>((ref) {
  // Use kIsWeb for web check, Platform.isMacOS for macOS check
  if (kIsWeb || Platform.isMacOS) {
    print("Platform check: Using JSON data source for Quran text.");
    // Create a single instance to be shared
    return JsonQuranTextService();
  } else {
    print(
      "Platform check: Not using JSON data source for Quran text on this platform (${Platform.operatingSystem}).",
    );
    return null; // Return null for iOS and other unsupported platforms
  }
});

/// FutureProvider responsible for initializing the [JsonQuranTextService].
/// This should be observed early in the app lifecycle (e.g., in main.dart via an observer)
/// on platforms where the JSON source is used.
final jsonDataSourceInitializerProvider = FutureProvider<void>((ref) async {
  final source = ref.watch(quranTextSourceProvider);
  // Only attempt initialization if the source exists for the current platform
  if (source != null) {
    print("Initializer: Initializing JSON Quran text data source...");
    await source.initialize();
    print("Initializer: JSON Quran text data source initialized.");
  } else {
    print("Initializer: No JSON data source to initialize for this platform.");
  }
});

// Note: If an API fallback for iOS was needed for Arabic text,
// you would define an ApiQuranTextDataSource implementing IQuranTextDataSource
// and potentially a combined provider that chooses between JSON and API based on platform.
// Since iOS will use the existing mechanism (fetching Arabic text along with other details),
// we only need the provider for the JSON source here.
