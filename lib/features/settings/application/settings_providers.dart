import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/core/services/shared_preferences_service.dart'; // Import the service

// Provider for showing/hiding translation
// Provider for showing/hiding translation, now connected to persistence
final showTranslationProvider = StateProvider<bool>((ref) {
  final prefsService = ref.watch(sharedPreferencesServiceProvider);
  // Read initial value from service
  final initialValue = prefsService.getShowTranslation();

  // Listen to changes in this provider's state and save to prefs
  ref.listenSelf((_, bool next) {
    prefsService.setShowTranslation(next);
  });

  return initialValue;
});

// Provider for showing/hiding transliteration
// Provider for showing/hiding transliteration, now connected to persistence
final showTransliterationProvider = StateProvider<bool>((ref) {
  final prefsService = ref.watch(sharedPreferencesServiceProvider);
  final initialValue = prefsService.getShowTransliteration();

  ref.listenSelf((_, bool next) {
    prefsService.setShowTransliteration(next);
  });

  return initialValue;
});

// Provider for selected font size scale factor (example)
// Provider for selected font size scale factor, now connected to persistence
final fontSizeScaleFactorProvider = StateProvider<double>((ref) {
  final prefsService = ref.watch(sharedPreferencesServiceProvider);
  final initialValue = prefsService.getFontSizeScaleFactor();

  ref.listenSelf((_, double next) {
    prefsService.setFontSizeScaleFactor(next);
  });

  return initialValue;
});

// Provider for selected reciter identifier (example)
// Provider for selected reciter identifier, now connected to persistence
final selectedReciterProvider = StateProvider<String?>((ref) {
  final prefsService = ref.watch(sharedPreferencesServiceProvider);
  final initialValue = prefsService.getSelectedReciter();

  ref.listenSelf((_, String? next) {
    prefsService.setSelectedReciter(next);
  });

  return initialValue;
});

// Provider for enabling/disabling autoplay
final autoplayEnabledProvider = StateProvider<bool>((ref) {
  final prefsService = ref.watch(sharedPreferencesServiceProvider);
  final initialValue = prefsService.getAutoplayEnabled();

  ref.listenSelf((_, bool next) {
    prefsService.setAutoplayEnabled(next);
  });

  return initialValue;
});
