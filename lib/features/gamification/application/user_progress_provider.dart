import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/core/models/user_progress.dart';
import 'package:quran_flutter/core/services/user_progress_hive_service.dart'; // Import Hive service
// Import for math functions like sin, pi

// StateNotifier for managing UserProgress
class UserProgressNotifier extends StateNotifier<UserProgress> {
  final UserProgressHiveService _hiveService;

  // Inject the Hive service and load initial state
  UserProgressNotifier(this._hiveService)
      : super(_hiveService.getUserProgress());

  // Method to add points
  void addPoints(int pointsToAdd) {
    state = state.copyWith(points: state.points + pointsToAdd);
    print('Points added: $pointsToAdd. Total points: ${state.points}');
    _saveState(); // Save state after modification
    // TODO: Check if verse completion should award points only once
  }

  // Method to add a badge ID if it hasn't been earned yet
  void addBadge(String badgeId) {
    if (!state.earnedBadgeIds.contains(badgeId)) {
      // Create a new set with the added badge ID
      final updatedBadges = Set<String>.from(state.earnedBadgeIds)
        ..add(badgeId);
      state = state.copyWith(earnedBadgeIds: updatedBadges);
      print(
        'Badge earned: $badgeId. Total badges: ${state.earnedBadgeIds.length}',
      );
      _saveState(); // Save state after modification
      // TODO: Potentially trigger a notification/celebration animation
    }
  }

  /// Marks a specific verse as completed.
  /// Takes surah number and verse number (within the surah) as input.
  void markVerseCompleted(int surahNumber, int verseNumber) {
    final verseKey = '$surahNumber-$verseNumber';
    if (!state.completedVerseKeys.contains(verseKey)) {
      final updatedKeys = Set<String>.from(state.completedVerseKeys)
        ..add(verseKey);
      state = state.copyWith(completedVerseKeys: updatedKeys);
      print('Verse completed: $verseKey');
      _checkAndAwardBadges(); // Check if completing this verse earned any badges
      _saveState();
    }
  }

  // Checks if any badges should be awarded based on current progress
  void _checkAndAwardBadges() {
    // Example: Award badge for completing Surah Al-Fatiha (Surah 1, 7 verses)
    if (!state.earnedBadgeIds.contains('surah_fatiha_complete')) {
      bool fatihaComplete = true;
      for (int i = 1; i <= 7; i++) {
        // Al-Fatiha has 7 verses
        if (!state.completedVerseKeys.contains('1-$i')) {
          fatihaComplete = false;
          break;
        }
      }
      if (fatihaComplete) {
        addBadge('surah_fatiha_complete');
      }
    }

    // Example: Award badge for listening to 10 verses
    if (!state.earnedBadgeIds.contains('ten_verses') &&
        state.completedVerseKeys.length >= 10) {
      addBadge('ten_verses');
    }

    // TODO: Add checks for other badges (streak badges, etc.)
  }

  /// Checks and updates the daily streak based on the last session date.
  /// Should be called once when the app starts or resumes.
  void updateStreakOnSessionStart() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // Define today here
    final lastSession = state.lastSessionDate;
    int currentStreak = state.currentStreak;

    if (lastSession == null) {
      // First session ever, start streak at 1
      currentStreak = 1;
      print("First session, starting streak.");
    } else {
      final difference = now.difference(lastSession).inDays;
      // final today = DateTime(now.year, now.month, now.day); // Moved definition up
      final lastSessionDay = DateTime(
        lastSession.year,
        lastSession.month,
        lastSession.day,
      );

      if (today.isAfter(lastSessionDay)) {
        // Only update if it's a new day
        if (difference == 1) {
          // Consecutive day
          currentStreak++;
          print("Streak continued! Current streak: $currentStreak");
          // TODO: Award streak badges if milestones are met (e.g., 3-day, 7-day)
        } else if (difference > 1) {
          // Streak broken, reset to 1 for today's session
          currentStreak = 1;
          print("Streak broken, resetting to 1.");
        }
        // If difference is 0, it's the same day, do nothing to streak
      } else {
        print("Session continued on the same day, streak unchanged.");
      }
    }

    // Update state only if streak changed or lastSessionDate needs updating
    // Also ensure we only update lastSessionDate if it's actually a new day compared to the stored one
    final bool isNewDay = state.lastSessionDate == null ||
        today.isAfter(
          DateTime(
            state.lastSessionDate!.year,
            state.lastSessionDate!.month,
            state.lastSessionDate!.day,
          ),
        );

    if (currentStreak != state.currentStreak || isNewDay) {
      state = state.copyWith(
        currentStreak: currentStreak,
        lastSessionDate: now, // Update last session time
      );
      _saveState();
    }
  }

// --- Bookmark Methods ---

  /// Adds a bookmark for the given surah and verse number.
  void addBookmark(int surahNumber, int verseNumber) {
    final newBookmark = {'surah': surahNumber, 'verse': verseNumber};
    // Check if already bookmarked to avoid duplicates (optional, List allows duplicates)
    if (state.bookmarks
        .any((b) => b['surah'] == surahNumber && b['verse'] == verseNumber)) {
      print('Verse $surahNumber:$verseNumber already bookmarked.');
      return; // Already bookmarked
    }

    final updatedBookmarks = List<Map<String, int>>.from(state.bookmarks)
      ..add(newBookmark);
    state = state.copyWith(bookmarks: updatedBookmarks);
    print('Bookmark added: $surahNumber:$verseNumber');
    _saveState();
  }

  /// Removes a bookmark for the given surah and verse number.
  void removeBookmark(int surahNumber, int verseNumber) {
    final updatedBookmarks = List<Map<String, int>>.from(state.bookmarks)
      ..removeWhere(
          (b) => b['surah'] == surahNumber && b['verse'] == verseNumber);

    // Check if anything was actually removed before updating state
    if (updatedBookmarks.length < state.bookmarks.length) {
      state = state.copyWith(bookmarks: updatedBookmarks);
      print('Bookmark removed: $surahNumber:$verseNumber');
      _saveState();
    } else {
      print('Bookmark not found: $surahNumber:$verseNumber');
    }
  }

  /// Checks if a specific verse is bookmarked.
  bool isBookmarked(int surahNumber, int verseNumber) {
    return state.bookmarks
        .any((b) => b['surah'] == surahNumber && b['verse'] == verseNumber);
  }

  // --- Last Read Verse Methods ---

  /// Updates the last read verse index for a given surah.
  void updateLastReadVerse(int surahNumber, int verseIndex) {
    // Avoid unnecessary updates if the index hasn't changed
    if (state.lastReadVerse[surahNumber] == verseIndex) {
      return;
    }
    // Create a mutable copy of the map
    final updatedLastRead = Map<int, int>.from(state.lastReadVerse);
    updatedLastRead[surahNumber] = verseIndex; // Update or add the entry
    state = state.copyWith(lastReadVerse: updatedLastRead);
    // Consider debouncing this save if called frequently during scroll
    _saveState();
    print('Last read verse updated for Surah $surahNumber: Index $verseIndex');
  }

  /// Gets the last read verse index for a given surah. Returns null if none recorded.
  int? getLastReadVerseIndex(int surahNumber) {
    return state.lastReadVerse[surahNumber];
  }

  // Helper method to save the current state to Hive
  Future<void> _saveState() async {
    await _hiveService.saveUserProgress(state);
  }
}

// StateNotifierProvider for UserProgress
final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgress>((ref) {
  // Get the Hive service instance
  final hiveService = ref.watch(userProgressHiveServiceProvider);
  // Pass the service to the notifier
  final notifier = UserProgressNotifier(hiveService);
  // Update streak when the provider is first created
  notifier.updateStreakOnSessionStart();
  return notifier;
});

// Simple provider to easily access just the points
final userPointsProvider = Provider<int>((ref) {
  return ref.watch(userProgressProvider).points;
});

// Provider to access the current streak
final currentStreakProvider = Provider<int>((ref) {
  return ref.watch(userProgressProvider).currentStreak;
});

// Provider to access the set of earned badge IDs
final earnedBadgesProvider = Provider<Set<String>>((ref) {
  return ref.watch(userProgressProvider).earnedBadgeIds;
});
