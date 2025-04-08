import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran_flutter/features/navigation/app_router.dart';
import 'package:quran_flutter/shared/theme/app_theme.dart';
import 'package:quran_flutter/core/services/shared_preferences_service.dart';
import 'package:quran_flutter/core/models/user_progress.dart';
import 'package:quran_flutter/core/observers/app_lifecycle_observer.dart';
import 'package:quran_flutter/core/providers/data_providers.dart'; // Import data providers
import 'package:flutter/foundation.dart' show kIsWeb; // For platform check
import 'dart:io' show Platform; // For platform check

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserProgressAdapter());
  await Hive.openBox<UserProgress>('userProgressBox');
  final prefs = await SharedPreferences.getInstance();

  // Create the ProviderContainer manually
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    // Removed AppInitializerObserver from here
  );

  // Initialize JSON data source if on supported platform BEFORE running the app
  if (kIsWeb || Platform.isMacOS) {
    print("Main: Pre-initializing JSON data source...");
    try {
      // Read the future from the initializer provider and wait for it
      await container.read(jsonDataSourceInitializerProvider.future);
      print("Main: JSON data source pre-initialized successfully.");
    } catch (e, s) {
      print("Main: Error during JSON data source pre-initialization: $e");
      print(s);
      // Decide how to handle initialization failure (e.g., show error, exit)
      // For now, we'll let the app continue, but text loading might fail later.
    }
  }

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
