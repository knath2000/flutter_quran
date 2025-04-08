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

  UserProgress({
    this.points = 0,
    // this.completedSurahNumbers = const {},
    this.earnedBadgeIds = const {},
    this.completedVerseKeys = const {}, // Initialize in constructor
    this.currentStreak = 0, // Initialize in constructor
    this.lastSessionDate, // Initialize (can be null)
  });

  // Method to create a copy with updated values
  UserProgress copyWith({
    int? points,
    // Set<int>? completedSurahNumbers,
    Set<String>? earnedBadgeIds,
    Set<String>? completedVerseKeys, // Add to copyWith parameters
    int? currentStreak, // Add to copyWith parameters
    DateTime? lastSessionDate,
  }) {
    return UserProgress(
      points: points ?? this.points,
      // completedSurahNumbers: completedSurahNumbers ?? this.completedSurahNumbers,
      earnedBadgeIds: earnedBadgeIds ?? this.earnedBadgeIds,
      completedVerseKeys:
          completedVerseKeys ?? this.completedVerseKeys, // Use in copyWith
      currentStreak: currentStreak ?? this.currentStreak, // Use in copyWith
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
    );
  }

  // TODO: Add fromJson/toJson methods if storing complex progress in Hive/Prefs
}
