import 'package:flutter/material.dart'; // Ensure Material widgets are imported
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/features/quran_reader/application/providers/surah_list_provider.dart';
// import 'package:quran_flutter/features/quran_reader/presentation/widgets/surah_grid_tile.dart'; // Not used in placeholder
import 'package:go_router/go_router.dart'; // For navigation
import 'package:quran_flutter/features/navigation/app_router.dart'; // For AppRoutes

class SurahJourneyMap extends ConsumerWidget {
  const SurahJourneyMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahListAsync = ref.watch(surahListProvider);

    // Use AsyncValue.when to handle loading/error/data states
    return surahListAsync.when(
      data: (surahs) {
        if (surahs.isEmpty) {
          return const Center(child: Text('No Surahs available for map.'));
        }

        // Use a Stack for layering map elements
        return Stack(
          children: [
            // TODO: Layer 1 - CustomPainter for drawing the path between Surahs
            // CustomPaint(painter: JourneyPathPainter(surahs: surahs), size: Size.infinite),

            // TODO: Layer 2 - Positioned widgets for each Surah node
            // This is a simplified example, actual positioning needs calculation
            ...surahs.map((surah) {
              // Example: Replace with calculated positions based on map design
              // For now, just using a simple placeholder layout
              return Positioned(
                // Placeholder positioning - replace with actual logic
                left: (surah.number % 5) * 80.0 + 20,
                top: (surah.number ~/ 5) * 120.0 + 20,
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.readerPath(surah.number)),
                  child: Tooltip(
                    // Add tooltip for accessibility/info
                    message: '${surah.englishName} (${surah.name})',
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        surah.number.toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Placeholder text (remove once map is implemented)
            Center(
              child: Text(
                'Journey Map Area\n(${surahs.length} Surahs)',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error loading Surah data for map: $error',
            style: const TextStyle(
              color: Colors.white,
            ), // Ensure text visibility
          ),
        ),
      ),
    );
  }
}
