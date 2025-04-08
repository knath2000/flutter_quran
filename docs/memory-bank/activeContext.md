# Active Context

## Current Focus

Successfully deploying the web application to Vercel and ensuring basic app functionality across platforms (Web, iOS, Android, macOS). Preparing project for open-source contribution via GitHub.

## Recent Changes

### GitHub & Vercel Deployment Setup (April 2025)

1.  **Git Initialization:** Initialized a local Git repository.
2.  **`.gitignore` Update:** Updated `.gitignore` to exclude sensitive Firebase credentials (`lib/firebase_options.dart`, `**/GoogleService-Info.plist`, `**/google-services.json`) and project-specific files/directories (`memory-bank/`, `.clinerules`, `docs/`). Crucially, the `build/` directory ignore rule was removed to allow committing web build artifacts.
3.  **GitHub Push:** Created an initial commit and pushed the project to the remote GitHub repository (`https://github.com/knath2000/flutter-planner.git`).
4.  **Vercel Configuration:**
    *   Iteratively configured Vercel deployment. Initial attempts using framework detection or explicit build commands failed due to issues finding the Flutter SDK or compiling with environment variables.
    *   Final successful configuration involves:
        *   Reverting `lib/main.dart` to use `DefaultFirebaseOptions.currentPlatform` (reading from `lib/firebase_options.dart`).
        *   Ensuring `lib/firebase_options.dart` is *not* ignored by Git.
        *   Committing the locally built `build/web` directory to the Git repository.
        *   Using a minimal `vercel.json` specifying only SPA rewrite rules (`{ "version": 2, "rewrites": [ { "source": "/(.*)", "destination": "/index.html" } ] }`).
        *   Configuring the Vercel project UI settings for a static deployment (Framework: `Other`, Build/Install commands: `OFF`, Output Directory: `build/web`).
5.  **Web Deployment:** Successfully deployed the web application to Vercel using the static deployment strategy.
6.  **Web Script Fixes:** Modified `web/index.html` to load Firebase JS SDKs using `type="module"` to resolve console errors. Removed reference to non-existent `Icon-144.png` in `web/manifest.json`.

### Web Optimization (April 2025)

We've implemented several optimizations for the web version:

1. **Performance Optimizations**:
   - Updated index.html with performance best practices
   - Added preloading and preconnecting for critical resources
   - Optimized JavaScript loading with defer
   - Added Firebase Performance Monitoring

2. **PWA Features**:
   - Enhanced manifest.json with better PWA configuration
   - Added custom service worker for offline capabilities
   - Created offline fallback page
   - Added support for additional icon sizes

3. **Offline Support**:
   - Implemented caching strategies for different resource types
   - Added offline fallback page
   - Implemented background sync for offline actions

### macOS Build & Distribution (April 2025)

1.  **App Store Submission Fix:** Resolved an App Store Connect submission error by adding the required `LSApplicationCategoryType` key (with value `public.app-category.productivity`) to `macos/Runner/Info.plist`. Submission was successful afterwards.
2.  **Basic DMG Creation:**
    *   Added `dmg: ^0.1.3` as a dev dependency.
    *   Built the release app (`flutter build macos --release`).
    *   Attempted to use `dart run dmg` but encountered issues with the package requiring signing certificates even when flags were omitted.
    *   Successfully created a basic, unsigned `.dmg` file (`Planner_Installer.dmg`) using a sequence of `hdiutil` commands. This DMG will likely trigger Gatekeeper warnings upon installation.

## Active Decisions

1. **Service Worker Strategy**: We're using a dual service worker approach:
   - Flutter's built-in service worker for Flutter-specific assets
   - Custom service worker for enhanced caching and offline features

2. **Performance Monitoring**: We've integrated Firebase Performance Monitoring to track:
   - App startup time
   - Page load performance
   - Network requests
   - UI rendering
   - Custom operations

3. **Caching Strategy**: We're using different caching strategies based on resource type:
   - Cache-first for static assets (images, fonts, etc.)
   - Network-first for API calls
   - Stale-while-revalidate for HTML navigation

## Next Steps

1.  **Testing:** Thoroughly test the deployed Vercel web application.
2.  **Web Optimizations:** Continue with planned web optimizations (Flutter integration, offline indicators, image optimization, etc.).
3.  **macOS DMG (Future):** Revisit creating a signed and notarized `.dmg` once Developer ID certificate and app-specific password are set up.
4.  **Cross-Platform Testing:** Test core functionality across all targeted platforms.

## Current Considerations

1.  **Vercel Deployment Strategy:** Current strategy requires committing `build/web` artifacts. Consider if a Vercel build process (using a custom build script or potentially a future official Flutter preset) is preferable long-term to avoid committing build output.
2.  **Firebase Config in Git:** `lib/firebase_options.dart` is now committed to Git. Ensure this is acceptable and doesn't expose overly sensitive information (API keys are generally considered safe to expose for web/client-side apps, but review security implications).
3.  **macOS Build State:** The `Release.entitlements` file appears correct for distribution, but signing/notarization prerequisites are not yet met for creating a fully trusted `.dmg`.
3.  **Browser Compatibility**: Ensure the PWA features work across all major browsers.
4.  **Performance Budget**: Establish performance budgets for key metrics.
5.  **Offline UX**: Improve the user experience when offline, including clear indicators and graceful degradation.
