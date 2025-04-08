import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Keys for storing settings
class PrefKeys {
  static const String showTranslation = 'showTranslation';
  static const String showTransliteration = 'showTransliteration';
  static const String fontSizeScaleFactor = 'fontSizeScaleFactor';
  static const String selectedReciter = 'selectedReciter';
  static const String autoplayEnabled = 'autoplayEnabled';
}

// Provider for SharedPreferences instance.
// This MUST be overridden in the main ProviderScope with the instance obtained in main().
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferencesProvider must be overridden');
});

// Provider for the service itself
final sharedPreferencesServiceProvider = Provider<SharedPreferencesService>((
  ref,
) {
  // Depend on the overridden provider
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  // No need for null check here as it's guaranteed to be overridden in main
  return SharedPreferencesService(sharedPrefs);
});

class SharedPreferencesService {
  final SharedPreferences? _prefs;

  SharedPreferencesService(this._prefs);

  // --- Getters ---

  bool getShowTranslation() {
    return _prefs?.getBool(PrefKeys.showTranslation) ?? true; // Default to true
  }

  bool getShowTransliteration() {
    return _prefs?.getBool(PrefKeys.showTransliteration) ??
        true; // Default to true
  }

  double getFontSizeScaleFactor() {
    return _prefs?.getDouble(PrefKeys.fontSizeScaleFactor) ??
        1.0; // Default to 1.0
  }

  bool getAutoplayEnabled() {
    return _prefs?.getBool(PrefKeys.autoplayEnabled) ??
        false; // Default to false
  }

  String? getSelectedReciter() {
    return _prefs?.getString(PrefKeys.selectedReciter) ??
        'ar.alafasy'; // Example default
  }

  // --- Setters ---

  Future<bool> setShowTranslation(bool value) async {
    return await _prefs?.setBool(PrefKeys.showTranslation, value) ?? false;
  }

  Future<bool> setShowTransliteration(bool value) async {
    return await _prefs?.setBool(PrefKeys.showTransliteration, value) ?? false;
  }

  Future<bool> setFontSizeScaleFactor(double value) async {
    return await _prefs?.setDouble(PrefKeys.fontSizeScaleFactor, value) ??
        false;
  }

  Future<bool> setSelectedReciter(String? value) async {
    if (value == null) {
      return await _prefs?.remove(PrefKeys.selectedReciter) ?? false;
    }
    return await _prefs?.setString(PrefKeys.selectedReciter, value) ?? false;
  }

  Future<bool> setAutoplayEnabled(bool value) async {
    return await _prefs?.setBool(PrefKeys.autoplayEnabled, value) ?? false;
  }
}
