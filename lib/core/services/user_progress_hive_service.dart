import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quran_flutter/core/models/user_progress.dart';

// Provider for the Hive box (lazy opening)
final userProgressBoxProvider = Provider<Box<UserProgress>>((ref) {
  // This assumes the box is already opened in main.dart
  // If not opened yet, Hive.box() will throw an error.
  // Consider using FutureProvider if opening here is preferred,
  // but opening in main ensures it's ready before the app runs.
  try {
    return Hive.box<UserProgress>('userProgressBox');
  } catch (e) {
    print(
      "Error accessing userProgressBox: $e. Ensure it was opened in main.dart",
    );
    // Depending on requirements, might rethrow or return a dummy/unopened box
    // For now, rethrowing might be safer to catch initialization issues early.
    rethrow;
  }
});

// Provider for the service
final userProgressHiveServiceProvider = Provider<UserProgressHiveService>((
  ref,
) {
  final box = ref.watch(userProgressBoxProvider);
  return UserProgressHiveService(box);
});

class UserProgressHiveService {
  final Box<UserProgress> _userProgressBox;
  // Use a fixed key to store the single UserProgress object
  static const String _userProgressKey = 'currentUserProgress';

  UserProgressHiveService(this._userProgressBox);

  /// Gets the current user progress from the box.
  /// Returns a default UserProgress if not found.
  UserProgress getUserProgress() {
    // Use .get() with a defaultValue for simplicity
    return _userProgressBox.get(_userProgressKey) ?? UserProgress();
  }

  /// Saves the user progress object to the box.
  Future<void> saveUserProgress(UserProgress progress) async {
    try {
      await _userProgressBox.put(_userProgressKey, progress);
      print("User progress saved to Hive.");
    } catch (e) {
      print("Error saving user progress to Hive: $e");
      // Handle error appropriately
    }
  }
}
