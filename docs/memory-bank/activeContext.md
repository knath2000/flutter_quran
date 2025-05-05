# Active Context

## Current Focus (as of commit 47f073a)

The focus shifted to UI layout refinement and bug fixing. Specifically:
1.  Refactoring the `QuranReaderScreen` layout to ensure the `SurahIntroductionCard` scrolls with the verses.
2.  Resolving a `TypeError` encountered when reading cached verse data from Hive in release builds.

## Recent Changes (Current Task)

*   **AI Translation API Migration:**
    *   Switched the AI translation service (`AiTranslationService`) from direct Google Gemini API calls to use the OpenRouter.ai API via the `dart_openai` package.
    *   Updated the service to use the `google/gemini-2.5-flash-preview` model via OpenRouter.
    *   Added `dart_openai` dependency (`^5.1.0`).
    *   Configured API key handling for OpenRouter using `--dart-define=OPENROUTER_API_KEY=YOUR_KEY`.
    *   Updated `build.sh` to include the new dart-define flag.

## Recent Changes (leading up to commit 47f073a)

*   **UI Layout Refactor (commit `064eb7a`):**
    *   Modified `QuranReaderScreen` (`lib/features/quran_reader/presentation/screens/quran_reader_screen.dart`) to use a single `ListView.builder` for both the `SurahIntroductionCard` (as the first item) and the `VerseTile` list. This replaced the previous `Column` + `Expanded` structure, making the introduction scrollable.
*   **Hive Cache Fix (commit `47f073a`):**
    *   Updated `QuranRepository` (`lib/features/quran_reader/data/repositories/quran_repository.dart`) to explicitly cast the data retrieved from the `quranVerseCache` Box using `List<Verse>.from()` to prevent `TypeError` in minified/release builds.
*   **(Previous changes up to commit `cc8a5ed` remain relevant):**
    *   Gemini API Integration (Service, API Key handling for *introductions*).
    *   State Management Refactor (`surahDetailsProvider` using record).
    *   UI Updates (Consuming combined state, deriving intro AsyncValue).
    *   Performance Optimizations (HTML renderer, deferred init, preconnect, source maps).
    *   Hive Caching Implementation (Verses and Introductions).

## Active Decisions

*   **Surah Introduction Source:** Google Gemini API (`gemini-2.0-flash`) is used for dynamic Surah introductions (via `GeminiSurahService` - *verify service name if different*).
*   **AI Translation Source:** OpenRouter.ai API (`google/gemini-2.5-flash-preview` model) is used for dynamic verse translations (via `AiTranslationService` and `dart_openai` package).
*   **API Key Handling:**
    *   `GEMINI_API_KEY` (for introductions) passed via `--dart-define`.
    *   `OPENROUTER_API_KEY` (for translations) passed via `--dart-define`.
*   **State Structure:**
    *   `surahDetailsProvider` manages combined verse and introduction data.
    *   `aiTranslationProvider` (likely `AsyncNotifierProvider.family`) manages translation state per verse.
*   **State Structure:** `surahDetailsProvider` manages a combined state `AsyncValue<(List<Verse>, String)>`.
*   **UI Integration:** `SurahIntroductionCard` displays the introduction fetched via `surahDetailsProvider`.
*   **QuranReaderScreen Layout:** Uses a single `ListView.builder` to display the introduction card followed by verse tiles, ensuring both scroll together.
*   **Web Renderer:** Explicitly using the HTML renderer for web builds.
*   **Caching Strategy:** Using Hive for local caching of verses and introductions.
*   **Hive Data Retrieval:** Explicitly casting data read from Hive boxes (e.g., `List<Verse>.from(rawData)`) is necessary to avoid runtime type errors, especially in release builds.

## Next Steps

1.  **Test OpenRouter Integration:** Thoroughly test the AI translation feature (swipe gesture, modal display) across different verses and network conditions. Verify correct API key usage and model selection. Test in debug and release modes (especially if local API key handling differs from CI/CD).
2.  **Test UI/Cache Fix:** Thoroughly test the `QuranReaderScreen` scrolling behavior and verify that the Hive cache `TypeError` is resolved across different Surahs and build modes (debug/release).
3.  **Test Gemini Integration (Introductions):** Thoroughly test the Surah introduction display across different Surahs and network conditions.
4.  **Refine Error Handling:** Improve error handling for both OpenRouter and Gemini API calls within their respective services/notifiers.
4.  **Performance Analysis:** Further investigate LCP element and main thread work using browser DevTools if needed.
5.  **Address Known Issues:** Revisit persistent issues (viewport accessibility, deprecated API) noting limitations.
6.  **Continue Core Feature Development:** Resume work on other planned features (e.g., user authentication, gamification, pagination).

## Current Considerations

*   **API Key Security:** Ensure the API key handling remains secure.
*   **Gemini API Costs/Quotas:** Monitor usage (for introductions).
*   **OpenRouter API Costs/Quotas:** Monitor usage (for translations).
*   **Hive Adapters:** Ensure Hive type adapters are regenerated if models change.
*   **Hive Casting:** Remember the necessity of explicit casting when reading complex types from Hive.
*   **Viewport Accessibility:** The `user-scalable=no` issue persists.
*   **Bundle Size:** Further JS bundle size reduction likely requires advanced analysis.
