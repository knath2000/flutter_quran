import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Remove the unused import for main.dart
import 'package:quran_flutter/features/quran_reader/presentation/screens/surah_selection_screen.dart'; // Keep this direct
import 'package:quran_flutter/features/quran_reader/presentation/screens/quran_reader_screen.dart'
    deferred as quran_reader;
import 'package:quran_flutter/features/settings/presentation/screens/settings_screen.dart'
    deferred as settings;
import 'package:quran_flutter/features/gamification/presentation/screens/badges_screen.dart'
    deferred as badges; // Import badges screen deferred

// Define route paths
class AppRoutes {
  static const String home = '/';
  // Add other route paths here as features are built
  static const String reader = '/reader/:surahNumber'; // Route with parameter
  static const String settings = '/settings';
  static const String badges = '/badges'; // Add badges route path

  // Helper method to create the reader path
  static String readerPath(int surahNumber) => '/reader/$surahNumber';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.home,
        builder: (BuildContext context, GoRouterState state) {
          // Point the home route to the SurahSelectionScreen
          return const SurahSelectionScreen();
        },
        routes: <RouteBase>[
          // Nested route for the reader screen
          GoRoute(
            path: 'reader/:surahNumber',
            // Use pageBuilder for custom transitions
            pageBuilder: (context, state) {
              final surahNumber =
                  int.tryParse(state.pathParameters['surahNumber'] ?? '1') ?? 1;
              // TODO: Optionally pass surah name via state.extra if needed
              // Apply a Fade Transition with FutureBuilder for deferred loading
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: FutureBuilder<void>(
                  future: quran_reader.loadLibrary(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        // Handle loading error (e.g., show an error message)
                        return Center(
                          child: Text(
                            'Error loading reader: ${snapshot.error}',
                          ),
                        );
                      }
                      // Library loaded, build the screen
                      return quran_reader.QuranReaderScreen(
                        surahNumber: surahNumber,
                      );
                    }
                    // Show loading indicator while waiting
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(
                  milliseconds: 300,
                ), // Adjust duration as needed
              );
            },
          ),
        ],
      ),
      // Settings Route (Top Level)
      GoRoute(
        path: AppRoutes.settings,
        // Apply a similar fade transition
        pageBuilder:
            (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: FutureBuilder<void>(
                future: settings.loadLibrary(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading settings: ${snapshot.error}',
                        ),
                      );
                    }
                    return settings.SettingsScreen();
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 300),
            ),
      ),
      // Badges Route (Top Level)
      GoRoute(
        path: AppRoutes.badges,
        pageBuilder:
            (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: FutureBuilder<void>(
                future: badges.loadLibrary(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error loading badges: ${snapshot.error}'),
                      );
                    }
                    return badges.BadgesScreen();
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 300),
            ),
      ),
    ],
    // Optional: Add error handling/redirects
    // errorBuilder: (context, state) => ErrorScreen(state.error),
  );
}
