# Progress (as of commit 4f10a98)

## What Works

### Core Functionality
- ✅ Basic Surah selection screen (`SurahSelectionScreen`).
- ✅ Basic Quran reader screen (`QuranReaderScreen`) displaying verses from local JSON (Web/macOS) or API (Other).
- ✅ Loading Quran text data from `assets/data/quran_arabic_text.json` (Web/macOS).
- ✅ Fetching verse details (Arabic, Translation, Audio, Transliteration) from `alquran.cloud` API.
- ✅ Displaying Arabic text, English Translation, and English Transliteration in `VerseTile`.
- ✅ Basic UI structure and navigation using GoRouter.
- ✅ Basic theme setup (`AppTheme`).
- ✅ Basic audio playback controls (play/pause/seek) per verse.
- ✅ Settings screen with functional toggles/options:
    - ✅ Font Size adjustment.
    - ✅ Show/Hide Translation toggle.
    - ✅ Show/Hide Transliteration toggle (Default: On).
    - ✅ Autoplay Verses toggle.
    - ✅ Reciter selection dropdown.
- ✅ Settings persistence using `SharedPreferences`.
- ✅ Surah Introduction Card UI displays dynamic introduction fetched from Gemini API.
    - ✅ Displays Surah title.
    - ✅ Displays fetched introduction text (expandable).
    - ✅ "View Full Content" / "Show Less" button toggles text expansion.
- ✅ Gemini API integration for Surah introductions functional.
- ✅ State management refactored (`surahDetailsProvider`) to handle combined verse and introduction data.
- ✅ API Key handling via `--dart-define` implemented for Vercel builds.

### Web Platform
- ✅ Vercel deployment setup functional.
- ✅ Basic web build output generation.
- ✅ Deferred loading implemented for `QuranReaderScreen`, `SettingsScreen`, `BadgesScreen`.
- ✅ Font preloading added to `index.html`.
- ✅ `robots.txt` is valid.
- ✅ `index.html` includes `lang="en"` attribute.
- ✅ Lighthouse SEO score: 100.
- ✅ Lighthouse Best Practices score: 100.
- ✅ Switched to HTML web renderer (`--web-renderer html`).
- ✅ Deferred Quran JSON data initialization in `main.dart`.
- ✅ Added preconnect links for fonts/API to `web/index.html`.
- ✅ Enabled source maps for web release builds (`--source-maps`).
- ✅ Fixed Vercel build issues related to Flutter SDK version and dependencies.

## In Progress

- **Gemini Introduction:** Introduction is fetched, but error handling and caching could be improved.
- **Web Performance Optimization:** Initial optimizations applied (HTML renderer, deferred init, preconnect). FCP/SI improved. LCP now measurable but high (3.2s in Lighthouse). Main thread work still significant. Further investigation needed (LCP element, DevTools analysis).
- **Accessibility:** Viewport issue (`user-scalable=no`) persists due to Flutter build behavior; fix requires non-standard workarounds.
- **Core Feature Development:**
    - Quran Reader UI enhancements.
    - State Management refinement (Riverpod).

## What's Left to Build (Major items from original plan)

- **Pagination:** Implementing verse pagination in the reader screen.
- **Audio Playback:** Enhancements (e.g., continuous play, playlist management).
- **User Progress/Gamification:** Features like tracking reading progress, badges, etc.
- **Data Persistence:** Moving beyond local JSON if needed (e.g., user data).
- **Authentication:** Adding user authentication.
- **Advanced Features:** Search, bookmarks, notes, etc.
- **Testing:** Comprehensive unit, widget, and integration tests.
- **Platform Enhancements:** PWA features, macOS specific improvements (signing, DMG).

## Known Issues

- **Gemini Error Handling:** Basic error handling for Gemini calls exists (prints to console, uses default text), but could be more user-facing.
- **Lighthouse LCP:** LCP is now measured but high (3.2s in Lighthouse simulation). Specific LCP element needs identification for targeted optimization.
- **JS Bundle Size:** Reduced by using HTML renderer, but overall JS execution time and main thread work remain high. Further reduction likely needs advanced analysis/code splitting.
- **Accessibility Viewport:** Lighthouse flags `user-scalable="no"` (Injected by Flutter build).
- **Deprecated API:** Lighthouse flags usage of a deprecated API (Specific API hard to identify).
// - **Missing Source Maps:** Source maps are now enabled in the build script.
- **Scrolling:** Potential scrolling issues in the `QuranReaderScreen` with large Surahs (pre-pagination state).
- **API Data:** Transliteration availability/accuracy depends on the `alquran.cloud` API.

*(Note: This progress reflects the state after initial performance optimizations up to commit `4f10a98`.)*
