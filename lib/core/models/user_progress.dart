import 'package:hive/hive.dart';

part 'user_progress.g.dart'; // Name of the generated file

// Represents the user's learning progress and gamification status.
@HiveType(typeId: 0) // Assign a unique typeId for Hive
class UserProgress {
  @HiveField(0) // Assign unique field indices
  final int points;
  @HiveField(4) // Next available index
  // Stores keys like "surahNumber-verseNumber", e.g., "1-7"
  final Set<String> completedVerseKeys;
  // final Set<int> completedSurahNumbers;
  @HiveField(1)
  final Set<String> earnedBadgeIds;
  @HiveField(2) // Next available index
  final int currentStreak;
  @HiveField(3)
  final DateTime? lastSessionDate;

  @HiveField(5) // New field for bookmarks
  final List<Map<String, int>> bookmarks; // e.g., [{'surah': 1, 'verse': 5}]

  @HiveField(6) // New field for last read verse per surah
  final Map<int, int>
      lastReadVerse; // e.g., {1: 5, 2: 25} (surahNumber: verseIndex)

  UserProgress({
    this.points = 0,
    // this.completedSurahNumbers = const {},
    this.earnedBadgeIds = const {},
    this.completedVerseKeys = const {},
    this.currentStreak = 0,
    this.lastSessionDate,
    this.bookmarks = const [], // Initialize bookmarks
    this.lastReadVerse = const {}, // Initialize lastReadVerse
  });

  // Method to create a copy with updated values
  UserProgress copyWith({
    int? points,
    // Set<int>? completedSurahNumbers,
    Set<String>? earnedBadgeIds,
    Set<String>? completedVerseKeys,
    int? currentStreak,
    DateTime? lastSessionDate,
    List<Map<String, int>>? bookmarks, // Add bookmarks to copyWith
    Map<int, int>? lastReadVerse, // Add lastReadVerse to copyWith
  }) {
    return UserProgress(
      points: points ?? this.points,
      // completedSurahNumbers: completedSurahNumbers ?? this.completedSurahNumbers,
      earnedBadgeIds: earnedBadgeIds ?? this.earnedBadgeIds,
      completedVerseKeys: completedVerseKeys ?? this.completedVerseKeys,
      currentStreak: currentStreak ?? this.currentStreak,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      bookmarks: bookmarks ?? this.bookmarks, // Use bookmarks in copyWith
      lastReadVerse:
          lastReadVerse ?? this.lastReadVerse, // Use lastReadVerse in copyWith
    );
  }

  // TODO: Add fromJson/toJson methods if storing complex progress in Hive/Prefs
}
