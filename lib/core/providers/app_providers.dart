import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Example Provider: Theme Mode (although currently only dark is used)
// This demonstrates the provider setup structure.
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  // Default to dark mode as per requirements
  return ThemeMode.dark;
  // Later, this could read from shared_preferences if a toggle is added
});

// Add other core/app-wide providers here as needed.
// For example:
// final apiClientProvider = Provider<Dio>((ref) => Dio());
// final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());
