# Active Context

## Current Focus (as of commit 8e47d5c)

The focus was on successfully integrating the Google Gemini API to dynamically fetch Surah introductions and display them in the `QuranReaderScreen`. This involved resolving API key handling issues, refactoring state management, and updating UI components.

## Recent Changes (leading up to commit 8e47d5c)

*   **Gemini API Integration:**
    *   Added `google_generative_ai` dependency.
    *   Created `GeminiSurahService` (`lib/core/services/gemini_surah_service.dart`) to handle API calls.
    *   Updated `build.sh` to pass the `GEMINI_API_KEY` via `--dart-define` for Vercel builds, resolving authentication errors.
*   **State Management Refactor:**
    *   Modified `SurahDetailsNotifier` (`lib/features/quran_reader/application/providers/surah_details_provider.dart`) state to hold both `List<Verse>` and the `String` introduction using a record `(List<Verse>, String)`.
    *   Updated `fetchSurah` method to call the `GeminiSurahService` once per Surah and combine results into the new state structure.
    *   Removed the incorrect `introduction` field previously added to the `Verse` model.
*   **UI Updates:**
    *   Updated `QuranReaderScreen` to consume the new combined state from `surahDetailsProvider`.
    *   Modified `QuranReaderScreen` to derive the `AsyncValue<String?>` for the introduction from the combined state and pass it correctly to `SurahIntroductionCard`.
    *   Updated `AppLifecycleObserver` to correctly access verse data from the new state record for autoplay logic.

## Active Decisions

*   **Surah Introduction Source:** Google Gemini API (`gemini-2.0-flash`) is used for dynamic Surah introductions.
*   **API Key Handling:** API key is passed via `--dart-define` during the build process, sourced from Vercel environment variables for deployment.
*   **State Structure:** `surahDetailsProvider` now manages a combined state `AsyncValue<(List<Verse>, String)>` to hold both verses and the introduction.
*   **UI Integration:** `SurahIntroductionCard` displays the introduction fetched via `surahDetailsProvider`.

## Next Steps

1.  **Test Gemini Integration:** Thoroughly test the Surah introduction display across different Surahs and network conditions.
2.  **Refine Error Handling:** Improve error handling for Gemini API calls within `SurahDetailsNotifier` (e.g., display a specific message if introduction fails).
3.  **UI Polish:** Review and potentially refine the styling and layout of the `SurahIntroductionCard` now that it displays real data.
4.  **Address Known Issues:** Revisit persistent issues like LCP measurement, viewport accessibility, etc. (if still relevant).
5.  **Continue Core Feature Development:** Resume work on other planned features (e.g., user authentication, gamification).

## Current Considerations

*   **API Key Security:** Ensure the API key handling remains secure, especially if considering other build environments.
*   **Gemini API Costs/Quotas:** Monitor usage of the Gemini API.
*   **Introduction Caching:** Consider caching generated introductions to reduce API calls and improve load times (currently fetched every time).
