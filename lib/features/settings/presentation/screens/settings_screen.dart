import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/features/settings/application/settings_providers.dart'; // Import providers

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Define available reciters (can be moved to a config/service later)
    final Map<String, String> availableReciters = {
      'ar.alafasy': 'Mishary Rashid Alafasy',
      'ar.abdulsamad': 'Abdul Samad',
      'ar.saoodshuraym': 'Saood bin Ibrahim Al-Shuraim', // Example
      // Add more based on API availability and child-friendliness
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Font Size Adjustment
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Font Size',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: ref.watch(fontSizeScaleFactorProvider),
                  min: 0.8, // Minimum scale factor
                  max: 1.5, // Maximum scale factor
                  divisions:
                      7, // Number of discrete steps (e.g., 0.8, 0.9, 1.0, ..., 1.5)
                  label: ref
                      .watch(fontSizeScaleFactorProvider)
                      .toStringAsFixed(1), // Display current value
                  onChanged: (double value) {
                    ref.read(fontSizeScaleFactorProvider.notifier).state =
                        value;
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
          const Divider(),
          // TODO: Implement Content Toggles (Translation, Transliteration)
          SwitchListTile(
            secondary: const Icon(Icons.translate),
            title: const Text('Show Translation'),
            value: ref.watch(
              showTranslationProvider,
            ), // Read state from provider
            onChanged: (bool value) {
              // Update state using the notifier
              ref.read(showTranslationProvider.notifier).state = value;
            },
            activeColor:
                Theme.of(context).colorScheme.primary, // Use theme accent
          ),
          SwitchListTile(
            secondary: const Icon(Icons.abc),
            title: const Text('Show Transliteration'),
            value: ref.watch(
              showTransliterationProvider,
            ), // Read state from provider
            onChanged: (bool value) {
              // Update state using the notifier
              ref.read(showTransliterationProvider.notifier).state = value;
            },
            activeColor:
                Theme.of(context).colorScheme.primary, // Use theme accent
          ),
          SwitchListTile(
            secondary: const Icon(Icons.playlist_play), // Use a suitable icon
            title: const Text('Autoplay Verses'),
            value: ref.watch(autoplayEnabledProvider), // Read state
            onChanged: (bool value) {
              // Update state
              ref.read(autoplayEnabledProvider.notifier).state = value;
            },
            activeColor:
                Theme.of(context).colorScheme.primary, // Use theme accent
          ),
          SwitchListTile(
            secondary: const Icon(Icons.history), // Icon for resuming
            title: const Text('Continue where you left off'),
            value: ref.watch(continueLastReadProvider), // Read state
            onChanged: (bool value) {
              // Update state
              ref.read(continueLastReadProvider.notifier).state = value;
            },
            activeColor:
                Theme.of(context).colorScheme.primary, // Use theme accent
          ),

          const Divider(),
          // Reciter Selection
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Audio Reciter',
                prefixIcon: const Icon(Icons.record_voice_over),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
              value: ref.watch(selectedReciterProvider),
              // TODO: Populate this list dynamically or from a config file
              items: const [
                DropdownMenuItem(
                  value: 'ar.alafasy',
                  child: Text('Mishary Rashid Alafasy'),
                ),
                DropdownMenuItem(
                  value: 'ar.abdulsamad',
                  child: Text('Abdul Samad'),
                ),
                // Add more reciters as needed
              ],
              onChanged: (String? newValue) {
                ref.read(selectedReciterProvider.notifier).state = newValue;
              },
              // Style the dropdown to match the theme
              dropdownColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }
}
