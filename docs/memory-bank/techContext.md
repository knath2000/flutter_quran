# Technical Context

## Technologies Used

### Frontend
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **Riverpod**: State management
- **go_router**: Navigation and routing

### Backend
- **Firebase**: Backend-as-a-Service
  - **Firestore**: NoSQL database for data storage
  - **Authentication**: User authentication
  - **Hosting**: Web app hosting
  - **Performance Monitoring**: Performance tracking and analysis
### External APIs
- **alquran.cloud API**: Used for fetching Quran data including:
  - Surah list metadata (`/meta`)
  - Verse details (`/surah/{surahNumber}/editions/...`) using editions:
    - Arabic Text: `quran-uthmani`
    - English Translation: `en.sahih`
    - Audio Recitation: `ar.alafasy` (configurable via settings)
    - English Transliteration: `en.transliteration` (configurable via settings)
- **Google Gemini API**: Used for dynamically generating Surah introductions.
  - Model: `gemini-2.0-flash`
  - Authentication: Requires `GEMINI_API_KEY` passed via `--dart-define` during build.

### Web Technologies
- **PWA**: Progressive Web App capabilities
- **Service Workers**: Offline support and caching
- **IndexedDB**: (via Firestore) Local data storage
- **Web Performance API**: Performance measurement

## Development Setup

### Environment
- Flutter SDK
- Firebase CLI
- Android Studio / VS Code
- Chrome DevTools for web debugging
- Xcode for macOS specific configuration (signing, entitlements, App Store submission)
- `hdiutil` (macOS built-in) for manual DMG creation

### Configuration
- Firebase project configuration in `firebase_options.dart`
- Environment-specific configurations
- Web-specific configurations in `web/index.html` and `web/manifest.json`
- API Key for Gemini passed via `--dart-define=GEMINI_API_KEY=$GEMINI_API_KEY` in `build.sh` for Vercel builds.
- Web renderer set to HTML (`--web-renderer html`) in `build.sh` for smaller initial load.
- Source maps enabled (`--source-maps`) in `build.sh` for release builds.

## Technical Constraints

### Platform Requirements
- iOS: iOS 11.0 or later
- Android: Android 5.0 (API level 21) or later
- macOS: macOS 10.15 (Catalina) or later (required by Firebase)
- Web: Modern browsers with IndexedDB and Service Worker support

### Cross-Platform Compatibility
- Must work on iOS, Android, and Web
- Must handle different screen sizes and orientations
- Must handle platform-specific features gracefully
- **macOS Signing:** Requires code signing (Personal Team or Developer ID) when entitlements like Keychain or Network Client are enabled. Command-line builds (`flutter build macos`) may fail signing even with automatic signing configured in Xcode.
  - **Workaround:** For local CLI builds, Network Client and Keychain entitlements are temporarily removed from `DebugProfile.entitlements` and `Release.entitlements`. This allows the build to succeed but breaks runtime Firebase Auth on macOS. Proper signing must be configured in Xcode, and entitlements restored for release builds.

### Offline Support
- Must work offline with limited functionality
- Must sync data when back online
- Must provide clear feedback about offline status

### Performance
- Must load quickly on all platforms
- Must handle large datasets efficiently
- Must minimize network usage
- Must optimize for mobile devices with limited resources

### Security
- Must secure user data
- Must validate inputs
- Must handle authentication securely
- Must implement proper access controls

## Dependencies

### Core
- `flutter`: Flutter framework
- `flutter_riverpod`: State management
- `go_router`: Routing

### Firebase
- `firebase_core`: Firebase core functionality
- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `firebase_performance`: Performance monitoring
### AI / Generative
- `google_generative_ai`: Google Gemini API SDK

### UI/UX
- `flutter_hooks`: UI state management
- `google_fonts`: Typography
- `flutter_animate`: Animations

### Utilities
- `uuid`: Unique ID generation
- `intl`: Internationalization and formatting
- `logger`: Logging

### Development/Build
- `dmg: ^0.1.3`: For creating macOS DMG files (added as dev dependency)

### Web-Specific
- Custom service worker for offline support
- Firebase Performance Monitoring JS SDK
- Web Vitals tracking

## Architecture

### State Management
- Riverpod providers for state management
- Repository pattern for data access
- Service pattern for business logic
- `surahDetailsProvider` uses a record `(List<Verse>, String)` to manage combined verse and introduction state.

### Data Flow
- Repositories provide streams of data
- UI subscribes to data streams
- User actions trigger repository methods
- Repository methods update Firestore
- Firestore updates trigger UI updates

### Web Optimizations
- Resource preloading (`<link rel="preload">` for fonts in `index.html`)
- Preconnecting (`<link rel="preconnect">` for fonts and API endpoints in `index.html`)
- Deferred script loading
- Service worker caching strategies
- Performance monitoring and tracking
- Offline fallback UI
- Deferred initialization of Quran JSON data (removed blocking `await` in `main.dart`).