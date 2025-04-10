# System Patterns

## Architecture

### Feature-First Architecture
The application is organized by features rather than by technical layers. Each feature has its own directory containing all related components:

```
lib/
  ├── features/
  │   ├── auth/
  │   │   ├── data/
  │   │   ├── domain/
  │   │   └── presentation/
  │   ├── projects/
  │   │   ├── data/
  │   │   ├── domain/
  │   │   └── presentation/
  │   └── tasks/
  │       ├── data/
  │       ├── domain/
  │       └── presentation/
  └── presentation/
      ├── common_widgets/
      ├── navigation/
      └── theme/
```

### Clean Architecture Principles
Each feature follows a simplified clean architecture approach:

1. **Data Layer**: Repositories and data sources
2. **Domain Layer**: Entities and business logic
3. **Presentation Layer**: UI components and state management

## Design Patterns

### Repository Pattern
- Repositories abstract data access from the rest of the application
- Each repository provides methods for CRUD operations
- Repositories return streams of data for reactive UI updates

### Provider Pattern (via Riverpod)
- Providers expose data and functionality to the UI
- UI components consume providers to access data
- Providers are composed to create complex data flows

### Service Pattern
- Services encapsulate business logic
- Services are injected into repositories or providers
- Services handle cross-cutting concerns

### Factory Pattern
- Used for creating complex objects
- Particularly for creating entities from JSON data

## State Management

### Riverpod Providers
- `StreamProvider`: For reactive data streams (e.g., from Firestore, though not currently used for main Quran data).
- `StateProvider`: For simple state management (e.g., `showTranslationProvider`, `showTransliterationProvider`, `fontSizeScaleFactorProvider`, `selectedReciterProvider`, `autoplayEnabledProvider`).
- `StateNotifierProvider`: For more complex state management (e.g., `audioPlaybackStateProvider`, `audioProgressProvider`, `surahDetailsProvider` which uses a record `(List<Verse>, String)` to hold combined data).
- `Provider`: For derived state and dependencies (e.g., `quranRepositoryProvider`, `sharedPreferencesServiceProvider`, `apiClientProvider`).
- `FutureProvider`: For asynchronous initialization or data fetching (e.g., `jsonDataSourceInitializerProvider`, `arabicJsonTextProvider`).

### State Flow
1. UI subscribes to providers
2. Providers watch repositories
3. Repositories stream data from Firestore
4. User actions trigger repository methods
5. Repository methods update Firestore
6. Firestore updates trigger UI updates

### Local Widget State
- For simple, self-contained UI state within a widget (like the expansion state of `SurahIntroductionCard`), `flutter_hooks` (specifically `useState`) is used to avoid the boilerplate of a full `StatefulWidget`.
## Navigation

### Go Router
- Declarative routing with GoRouter
- Route parameters for dynamic routes
- Nested routes for complex navigation
- Route guards for authentication

## Web Optimization Patterns

### Resource Loading Strategy
- **Preloading**: Fonts preloaded via `<link rel="preload">` in `index.html`.
- **Preconnecting**: Connections to font/API origins established early via `<link rel="preconnect">` in `index.html`.
- **Deferred Loading (Code Splitting)**: Major routes (`QuranReaderScreen`, `SettingsScreen`, `BadgesScreen`) loaded using `deferred as` and `loadLibrary()`.
- **Deferred Loading (Initialization)**: Quran JSON data source initialization deferred (removed blocking `await` from `main.dart`) to improve FCP.
- **Async Loading**: `flutter_bootstrap.js` uses `async`.

### Service Worker Caching Strategies
- **Cache-First**: Static assets (images, fonts, etc.)
- **Network-First**: API calls and dynamic content
- **Stale-While-Revalidate**: HTML navigation and UI updates
- **Network with Cache Fallback**: Default strategy

### Performance Monitoring
- **Custom Traces**: Track specific operations
- **HTTP Metrics**: Monitor network requests
- **User Timing**: Track user interactions
- **Resource Timing**: Monitor resource loading
- **Long Tasks**: Detect potential UI jank

### Offline Experience
- **Background Sync**: Queue operations when offline
- **Offline Fallback**: Show offline UI when disconnected
- **Cached Data Access**: Access previously loaded data when offline

## Error Handling

### Try-Catch Pattern
- Repository methods use try-catch for error handling
- Errors are logged and propagated to the UI
- UI shows appropriate error messages

### Result Pattern
- Some operations return a Result object
- Result can be Success or Error
- UI handles both cases appropriately

## Testing

### Repository Testing
- Repositories are tested with mock data sources
- Tests verify CRUD operations
- Tests verify error handling

### Provider Testing
- Providers are tested with mock repositories
- Tests verify state changes
- Tests verify dependencies

### UI Testing
- Widget tests verify UI behavior
- Integration tests verify feature workflows
- Golden tests verify UI appearance