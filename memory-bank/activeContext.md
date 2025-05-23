# Active Context: Quran Adventures (Phase 4/5 In Progress)

## 1. Current Work Focus

*   Continuing with Phase 5 (Gamification Layer) and Phase 4 (Advanced Animations & Engagement).
*   Focus on implementing remaining gamification logic (other badges), refining UI/animations (journey map, Rive), and adding tests.

## 2. Recent Changes

*   **Bookmark UI/UX (Phase 4 - Implemented):**
    *   Removed bookmark icon from `VerseTile`.
    *   Implemented long-press gesture on `VerseTile` to toggle bookmark status.
    *   Added SnackBar and haptic feedback for bookmark actions.
    *   Implemented brightness/luminosity effect (brighter background, text glow) for bookmarked `VerseTile` using conditional styling and `DecoratedBox` with `BoxShadow`. (Removed previous shimmer border attempts).
*   **Auto-Scroll on Playback (Phase 4 - Implemented):**
    *   Integrated `scrollable_positioned_list` into `QuranReaderScreen`.
    *   Added `ref.listen` on `audioPlaybackStateProvider` to detect verse changes.
    *   Implemented logic to automatically scroll the list using `ItemScrollController.scrollTo` to keep the currently playing verse in view (aligned near top).
    *   Corrected property access for verse number in `PlayingVerseIdentifier`.
*   **AI Translation (Phase 4 - Implemented):**
    *   Switched API key management from `flutter_dotenv` to `--dart-define`.
    *   Created `AiTranslationService` using `google_generative_ai` package to call Gemini API (`gemini-1.5-flash` model used due to issues with 2.5-preview) with a specific prompt. Key accessed via `String.fromEnvironment`.
    *   Added `aiTranslationEnabledProvider` setting and UI toggle in `SettingsScreen`.
    *   Created `aiTranslationProvider` (AsyncNotifierProvider.family) for state management.
    *   Implemented right-to-left swipe gesture on `VerseTile` using `GestureDetector`.
    *   Swipe triggers a modal bottom sheet (`showModalBottomSheet`) displaying the AI translation (or loading/error state).
*   **Known Issue (Autoplay Skipping):** Multiple attempts to fix autoplay skipping verses (esp. on macOS/Web) using manual logic, delays, and state flags were unsuccessful. The root cause appears to be rapid/spurious `completed` state events from `just_audio` after `playVerse` is called for the next track. **Decision:** Defer fixing this issue for now to proceed with Vercel deployment. Current implementation uses manual logic triggered by `AppLifecycleObserver`.
*   **Local Arabic Text (Web/macOS - Phase 4 - Implemented):**
    *   Added `csv` dev dependency & pre-processing script (`tool/process_quran_csv.dart`).
    *   Generated `assets/data/quran_arabic_text.json` from `assets/wbw.csv`.
    *   Declared `assets/data/` in `pubspec.yaml`.
    *   Created `JsonQuranTextService` with `Completer`-based initialization.
    *   Created platform-specific `quranTextSourceProvider` & `jsonDataSourceInitializerProvider`.
    *   Updated `main.dart` to explicitly `await` the initializer provider at startup.
    *   Created `arabicJsonTextProvider` & updated `VerseTile` for conditional text loading (JSON vs API), awaiting initializer.
    *   **Verified:** Text loads correctly from JSON on macOS/Web and from API on iOS without freezing.
*   **Bug Fix (Verse Tap iOS - Verified):** Moved `InkWell` in `VerseTile` to wrap the entire `Card`. Verified working.
*   **Audio Controls Update (Verified):** Made Stop button conditional, removed explicit Play/Pause from `VerseTile`, added Autoplay indicator. Verified working.
*   **Navigation Fix (Verified):** Used `context.push` for Settings/Badges. Back button verified.
*   **Autoplay Setting (Phase 4):** Added setting state/persistence/provider & UI toggle.
*   **Audio Playback Enhancement (Phase 4):** Created state/progress notifiers/providers, refactored service/tile for reactive UI.
*   **UI Refinements:** Centered VerseTile translation, centered SurahSelectionScreen list items, removed SurahSelectionScreen AppBar title.
*   **Theme Update:** Matched AppBar background to scaffold.
*   **Bug Fixes:** Added macOS network entitlements, temporarily commented out missing Rive animation.
*   Completed Phases 1-3.
*   Initialized Memory Bank.
*   **Refactor (Surah Introductions):** Removed the unused `SurahIntroductionService`, `surahIntroductionProvider`, and `assets/data/surah_introductions.json`. Consolidated introduction fetching logic within `surah_details_provider` to use `GeminiSurahService` exclusively, with caching via `surahIntroductionCache` Hive box. Fixed resulting import error in `quran_reader_screen.dart`.
## 3. Next Steps

*   **Gamification (Phase 5):** Implement logic for awarding other badges (e.g., streak milestones), refine BadgesScreen UI, implement visual progress map/journey concept for Surah selection.
*   **Advanced Animations (Phase 4):** Obtain/Create & Integrate actual Rive/Lottie animations (including `background_effect.riv`), uncomment Rive widget in `SurahSelectionScreen`.
*   **Refinement (Ongoing):** Implement dynamic reciter list source in Settings, refine error handling/loading states, add tests (especially for audio logic), **revisit autoplay skipping issue**.

## 4. Active Decisions & Considerations

*   **Autoplay Implementation:** Using manual logic triggered by `AppLifecycleObserver`. **Known Issue:** Skips verses on Web/macOS due to rapid state transitions. Fix deferred.
*   **Arabic Text Source:** Using pre-processed JSON asset on Web/macOS. iOS uses API data. Verified working.
*   **Audio Controls:** Stop button (conditional), Autoplay indicator, Tap-to-play `VerseTile`. Verified working.
*   **Navigation:** Using `context.push` for top-level routes from Home. Verified working.
*   **Audio Completion Logic:** Game logic triggered by `AppLifecycleObserver`.
*   **Text Sync:** Highlighting active `VerseTile`. Word-by-word sync deferred.
*   **Finalize API Choice & Editions:** Still pending.
*   **Font Selection:** Confirm `Nunito` variant.
*   **Asset Design:** Still need visual assets (Rive/Lottie).
*   **Gamification Rules:** Still need definition.
*   **Persistence:** Still using Hive/SharedPreferences split.
*   **Surah Selection UI:** Still basic list view.
*   **Surah Introduction Source:** Exclusively uses Google Gemini API (`gemini-1.5-flash` model via `GeminiSurahService`) called from `surah_details_provider`, with results cached in the `surahIntroductionCache` Hive box. The previous local JSON asset implementation has been removed.
*   **AI Translation Source:** Uses Google Gemini API (`gemini-1.5-flash` model via `AiTranslationService`). Requires `GEMINI_API_KEY` passed via `--dart-define`.