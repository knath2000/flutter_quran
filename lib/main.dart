import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran_flutter/features/navigation/app_router.dart';
import 'package:quran_flutter/shared/theme/app_theme.dart';
import 'package:quran_flutter/core/services/shared_preferences_service.dart';
import 'package:quran_flutter/core/models/user_progress.dart';
import 'package:quran_flutter/core/models/verse.dart'; // Import Verse for adapter/box typing
import 'package:quran_flutter/core/observers/app_lifecycle_observer.dart';
import 'package:quran_flutter/core/providers/data_providers.dart'; // Import data providers
import 'package:flutter/foundation.dart' show kIsWeb; // For platform check
import 'dart:io' show Platform; // For platform check

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Register adapters
  Hive.registerAdapter(UserProgressAdapter());
  // TODO: Ensure VerseAdapter is generated and registered here
  // Hive.registerAdapter(VerseAdapter()); // Assuming adapter exists/will be generated

  // Open boxes
  await Hive.openBox<UserProgress>('userProgressBox');
  await Hive.openBox<List<dynamic>>(
      'quranVerseCache'); // Store list of verses (dynamic for now if adapter not ready)
  await Hive.openBox<String>(
      'surahIntroductionCache'); // Store introduction strings
  final prefs = await SharedPreferences.getInstance();

  // Create the ProviderContainer manually
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    // Removed AppInitializerObserver from here
  );

  // Removed explicit pre-initialization of JSON data source.
  // It will now initialize lazily when first requested by a provider.
  // if (kIsWeb || Platform.isMacOS) {
  //   print("Main: Pre-initializing JSON data source...");
  //   try {
  //     await container.read(jsonDataSourceInitializerProvider.future);
  //     print("Main: JSON data source pre-initialized successfully.");
  //   } catch (e, s) {
  //     print("Main: Error during JSON data source pre-initialization: $e");
  //     print(s);
  //   }
  // }

  runApp(
    // Use UncontrolledProviderScope with the existing container
    UncontrolledProviderScope(
      container: container,
      // AppLifecycleObserver still needed for game logic on completion
      child: const AppLifecycleObserver(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Quran Adventures',
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}

// Removed AppInitializerObserver class definition
// Removed MyHomePage (unused default counter app code)
