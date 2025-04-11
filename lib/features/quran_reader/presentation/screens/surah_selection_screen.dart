import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:quran_flutter/features/navigation/app_router.dart'; // Import AppRoutes
import 'package:quran_flutter/features/quran_reader/application/providers/surah_list_provider.dart';
import 'package:quran_flutter/shared/widgets/starry_background.dart';
import 'package:quran_flutter/features/gamification/application/user_progress_provider.dart';
import 'package:quran_flutter/features/quran_reader/presentation/widgets/surah_journey_map.dart'; // Import the map widget
import 'package:rive/rive.dart' hide LinearGradient; // Hide conflicting name

class SurahSelectionScreen extends ConsumerWidget {
  const SurahSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider that fetches the list of Surahs
    final surahListAsync = ref.watch(surahListProvider);

    // Use theme's scaffold background color implicitly
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Select Surah'), // Title removed as requested
        actions: [
          // Points Display
          Padding(
            padding: EdgeInsets.only(
              right: 8.0,
            ), // Cannot be const due to Theme access below
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 4), // Cannot be const due to ref.watch above
                  // Watch the simple points provider
                  Text(
                    ref.watch(userPointsProvider).toString(),
                    style: TextStyle(
                      // Cannot be const due to ref.watch
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Streak Display
          Padding(
            padding: EdgeInsets.only(right: 8.0), // Cannot be const
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orangeAccent,
                    size: 20,
                  ), // Fire icon for streak
                  SizedBox(width: 4), // Cannot be const
                  Text(
                    ref
                        .watch(currentStreakProvider)
                        .toString(), // Watch streak provider
                    style: TextStyle(
                      // Cannot be const
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Settings Button
          IconButton(
            icon: Icon(Icons.settings_outlined), // Cannot be const
            tooltip: 'Settings',
            onPressed: () {
              context.push(AppRoutes.settings); // Use push to keep stack
            },
          ),
          // Badges Button
          IconButton(
            icon: Icon(Icons.emoji_events_outlined), // Cannot be const
            tooltip: 'My Badges',
            onPressed: () {
              // Navigate to the badges screen
              context.push(AppRoutes.badges); // Use push to keep stack
            },
          ),
        ],
      ),
      // Use a Stack to layer the background and content
      body: Stack(
        children: [
          // Layer 1: Starry Background
          StarryBackground(
            starColor: Theme.of(context).colorScheme.primary.withOpacity(
              0.7,
            ), // Gold stars, slightly transparent
            numberOfStars: 100, // Adjust count as needed
          ),
          // Layer 2: Rive Animation (e.g., subtle background movement)
          // Positioned.fill(
          //   // Example positioning
          //   child: RiveAnimation.asset(
          //     'assets/rive/background_effect.riv', // <<< REQUIRES ACTUAL .riv FILE
          //     fit: BoxFit.cover,
          //     // TODO: Specify animation name if needed: animation: 'idle',
          //   ),
          // ),
          // Layer 3: Gradient Overlay Container
          Container(
            // Apply the gradient decoration (optional, could remove if NightSky is sufficient)
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(
                    0.6,
                  ), // Semi-transparent gradient overlay
                  Theme.of(context).colorScheme.surface.withOpacity(0.85),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Layer 4: Main Content (AsyncValue.when)
          surahListAsync.when(
            data: (surahs) {
              if (surahs.isEmpty) {
                return Center(
                  // Can be const
                  child: const Text(
                    'No Surahs found. Check API connection or response.',
                    style: TextStyle(
                      // Can be const
                      color: Colors.white,
                    ),
                  ),
                );
              }
              // Replace GridView with the Journey Map placeholder
              // Display the list of Surahs using ListView.builder
              return ListView.builder(
                itemCount: surahs.length,
                itemBuilder: (context, index) {
                  final surah = surahs[index];
                  // Use Padding + Column + InkWell for centering and tap
                  return InkWell(
                    onTap: () {
                      // Navigate to the Quran Reader screen, passing the surah number
                      context.go(
                        AppRoutes.readerPath(surah.number),
                      ); // Use path helper
                    },
                    child: Padding(
                      // Can be const
                      padding: EdgeInsets.symmetric(
                        // Can be const
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .center, // Center children horizontally
                        children: [
                          Text(
                            '${surah.number}. ${surah.englishName}',
                            style:
                                Theme.of(
                                  context,
                                ).textTheme.titleLarge, // Larger title style
                          ),
                          SizedBox(
                            height: 4,
                          ), // Cannot be const due to Theme access below
                          Text(
                            surah.name, // Arabic name
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface
                                  .withOpacity(0.7), // Slightly dimmer color
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading:
                () => Center(
                  child: const CircularProgressIndicator(),
                ), // Can add const
            error: (error, stackTrace) {
              print('Error loading Surah list UI: $error\n$stackTrace');
              return Center(
                child: Padding(
                  // Can be const
                  padding: EdgeInsets.all(16.0), // Can be const
                  child: Text(
                    'Failed to load Surahs. Please check your connection.\nError: $error',
                    style: TextStyle(
                      // Cannot be const due to error variable
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ), // End surahListAsync.when
        ], // End Stack children
      ), // End body: Stack
    );
  }
}
