# Progress (as of commit 02a2c77)

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
- ✅ Surah Introduction Card UI implemented in `QuranReaderScreen` (using placeholder text).
    - ✅ Displays Surah title.
    - ✅ Displays truncated introduction text.
    - ✅ "Read More" / "Show Less" button toggles text expansion.

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

- **Surah Introduction Data:** Need to implement fetching/loading of actual introduction text to replace placeholder.
- **Web Performance Optimization:** Ongoing efforts to improve initial load time and address Core Web Vitals. LCP measurement remains problematic.
- **Accessibility:** Investigating how to fix the persistent `user-scalable=no` viewport issue flagged by Lighthouse.
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

- **Placeholder Data:** Surah Introduction Card currently uses static placeholder text.
- **Lighthouse LCP Error:** Lighthouse consistently fails to measure Largest Contentful Paint ("NO_LCP") for the Flutter Web build.
- **Large Initial Bundle:** `main.dart.js` remains large, impacting initial web load time.
- **Accessibility Viewport:** Lighthouse flags `user-scalable="no"` in the viewport meta tag.
- **Deprecated API:** Lighthouse flags usage of deprecated `IntlV8BreakIterator`.
- **Missing Source Maps:** Lighthouse flags missing source maps (needs verification).
- **Scrolling:** Potential scrolling issues in the `QuranReaderScreen` with large Surahs (pre-pagination state).
- **API Data:** Transliteration availability/accuracy depends on the `alquran.cloud` API.

*(Note: This progress reflects the state after implementing the Surah Introduction Card UI up to commit `02a2c77`.)*
