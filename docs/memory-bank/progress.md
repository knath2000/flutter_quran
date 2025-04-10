# Progress (as of commit 99eb9ae)

## What Works

### Core Functionality
- ✅ Basic Surah selection screen (`SurahSelectionScreen`).
- ✅ Basic Quran reader screen (`QuranReaderScreen`) displaying verses from local JSON.
- ✅ Loading Quran text data from `assets/data/quran_arabic_text.json`.
- ✅ Basic UI structure and navigation using GoRouter.
- ✅ Basic theme setup (`AppTheme`).

### Web Platform
- ✅ Vercel deployment setup functional.
- ✅ Basic web build output generation.
- ✅ Deferred loading implemented for `QuranReaderScreen`, `SettingsScreen`, `BadgesScreen`.
- ✅ Font preloading added to `index.html`.
- ✅ `robots.txt` is valid.
- ✅ `index.html` includes `lang="en"` attribute.
- ✅ Lighthouse SEO score: 100.
- ✅ Lighthouse Best Practices score: 100.

## In Progress

- **Web Performance Optimization:** Ongoing efforts to improve initial load time and address Core Web Vitals. LCP measurement remains problematic.
- **Accessibility:** Investigating how to fix the persistent `user-scalable=no` viewport issue flagged by Lighthouse.
- **Core Feature Development:** (Paused during performance optimization)
    - Quran Reader UI enhancements.
    - State Management refinement (Riverpod).

## What's Left to Build (Major items from original plan)

- **Pagination:** Implementing verse pagination in the reader screen.
- **Audio Playback:** Adding audio playback functionality for verses.
- **User Progress/Gamification:** Features like tracking reading progress, badges, etc.
- **Settings:** Implementing user-configurable settings.
- **Data Persistence:** Moving beyond local JSON if needed (e.g., user data).
- **Authentication:** Adding user authentication.
- **Advanced Features:** Search, bookmarks, notes, etc.
- **Testing:** Comprehensive unit, widget, and integration tests.
- **Platform Enhancements:** PWA features, macOS specific improvements (signing, DMG).

## Known Issues

- **Lighthouse LCP Error:** Lighthouse consistently fails to measure Largest Contentful Paint ("NO_LCP") for the Flutter Web build (both CanvasKit and HTML renderers tested). This seems related to Flutter's initialization/rendering process and the large initial JS bundle.
- **Large Initial Bundle:** `main.dart.js` remains large (~2.7MB-4MB depending on build), contributing to significant initial load and JS execution time.
- **Accessibility Viewport:** Lighthouse flags `user-scalable="no"` in the viewport meta tag, preventing zooming. Attempts to fix via `index.html` were overridden by the Flutter build process.
- **Deprecated API:** Lighthouse flags usage of deprecated `IntlV8BreakIterator` (likely from a dependency).
- **Missing Source Maps:** Lighthouse flags missing source maps, despite building with `--source-maps`. (Needs verification if maps are correctly deployed/accessible).
- **Scrolling:** Potential scrolling issues in the `QuranReaderScreen` if the number of verses is large (pre-pagination state).

*(Note: This progress reflects the state after attempting web performance optimizations up to commit `99eb9ae`.)*
