import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/core/services/ai_translation_service.dart';

// Use a simple class or record for the family argument
// Ensure proper equality and hashCode for Riverpod family caching
class VerseIdentifier {
  final int surahNumber;
  final int verseNumber;

  VerseIdentifier(this.surahNumber, this.verseNumber);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerseIdentifier &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          verseNumber == other.verseNumber;

  @override
  int get hashCode => surahNumber.hashCode ^ verseNumber.hashCode;

  @override
  String toString() {
    return 'VerseIdentifier($surahNumber:$verseNumber)';
  }
}

// AsyncNotifierProvider Family
final aiTranslationProvider = AsyncNotifierProvider.family<
    AiTranslationNotifier, String, VerseIdentifier>(
  () => AiTranslationNotifier(),
  name: 'aiTranslationProvider', // Optional: Add name for debugging
);

class AiTranslationNotifier
    extends FamilyAsyncNotifier<String, VerseIdentifier> {
  // Keep track if fetch was already triggered for this specific verseId instance
  // This helps prevent re-fetching if the widget rebuilds but the verseId hasn't changed.
  // Note: Riverpod family caching handles not creating new notifiers for the same arg.
  bool _fetchAttempted = false;

  @override
  FutureOr<String> build(VerseIdentifier arg) {
    // Don't fetch automatically on build, wait for explicit call via fetchTranslation()
    // Reset fetch attempt flag when the notifier is built (or rebuilt for a new arg)
    _fetchAttempted = false;
    // Return an initial non-loading, non-error state.
    // An empty string signifies "not yet fetched".
    // We could also use a custom state object if more complex initial state is needed.
    return "";
  }

  Future<void> fetchTranslation() async {
    // Prevent fetching if already loading, already fetched successfully for this instance,
    // or already in an error state for this instance.
    if (state.isLoading || _fetchAttempted || state.hasError) {
      print(
          "Skipping fetch for $arg: isLoading=${state.isLoading}, fetchAttempted=$_fetchAttempted, hasError=${state.hasError}");
      return;
    }

    print("Attempting to fetch AI translation for $arg");
    _fetchAttempted = true; // Mark that we are attempting the fetch
    state = const AsyncLoading(); // Set state to loading

    final service = ref.read(aiTranslationServiceProvider);
    final verseId = arg; // Access the family argument passed during build

    // Use AsyncValue.guard to handle potential errors from the service call
    state = await AsyncValue.guard(
      () =>
          service.fetchAiTranslation(verseId.surahNumber, verseId.verseNumber),
    );

    // Optional: Add logging for success/failure after the attempt
    if (state.hasError) {
      print("Error fetching AI translation for $arg: ${state.error}");
    } else {
      print("Successfully fetched AI translation for $arg");
    }
  }
}
