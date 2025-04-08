import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Remove the unused import for main.dart
import 'package:quran_flutter/features/quran_reader/presentation/screens/surah_selection_screen.dart';
import 'package:quran_flutter/features/quran_reader/presentation/screens/quran_reader_screen.dart';
import 'package:quran_flutter/features/settings/presentation/screens/settings_screen.dart';
import 'package:quran_flutter/features/gamification/presentation/screens/badges_screen.dart'; // Import badges screen

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
              final readerScreen = QuranReaderScreen(surahNumber: surahNumber);

              // Apply a Fade Transition
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: readerScreen,
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
              child: const SettingsScreen(),
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
              child: const BadgesScreen(),
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
