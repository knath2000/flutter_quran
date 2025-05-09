# Technical Context: Quran Adventures

## 1. Core Technologies

*   **Language:** Dart (latest stable SDK version)
*   **Framework:** Flutter (latest stable SDK version)
*   **Target Platforms:** macOS, Web, iOS (in priority order)

## 2. Key Libraries & Packages (Initial Selection)

*   **State Management:** `flutter_riverpod` / `riverpod`
*   **Navigation:** `go_router`
*   **Audio Playback:** `just_audio`
*   **Animations:** `rive`, `lottie`
*   **Data Fetching:** `dio`
*   **Data Persistence:** `shared_preferences`, `hive` / `hive_flutter`
*   **API Key Management:** `--dart-define` compile-time variables (preferred over `flutter_dotenv`).
*   **UI/General:** `google_fonts`, `flutter_svg` (potentially)
*   **Testing:** `flutter_test`, `integration_test`, `mocktail`

*(Note: This list will evolve as development progresses)*

## 3. Development Setup & Environment

*   **IDE:** VS Code (Assumed, based on user environment)
*   **Version Control:** Git (Assumed, standard practice)
*   **Build Environment:** Standard Flutter build tools (`flutter build ...`)
*   **Operating System (Dev):** macOS (Based on user environment)

## 4. Technical Constraints & Considerations

*   **Performance:** Must maintain smooth performance despite heavy animation usage, especially on Web and potentially lower-spec iOS devices. Requires careful optimization and testing.
*   **Platform Differences:** Need to account for UI/UX differences and potential API variations between macOS, Web, and iOS.
*   **API Dependencies:** Reliant on external public APIs (`alquran.cloud`, Google Gemini) for core content. Need robust error handling, caching, and potential fallbacks. API rate limits or changes could impact the app.
*   **Gemini API Key:** Requires a `GEMINI_API_KEY` environment variable. This is passed to the application at compile time using the `--dart-define=GEMINI_API_KEY=YOUR_KEY` flag during the build process (e.g., in `build.sh` for Vercel). The key is accessed in Dart code using `String.fromEnvironment('GEMINI_API_KEY')`. For local development, this flag needs to be added to the run/debug configuration (e.g., in VS Code's `launch.json`).
*   **Asset Management:** Requires management of potentially large audio files and animation assets (Rive/Lottie files). Consider asset bundling strategies or on-demand downloading/caching. (Local JSON for introductions removed).
*   **Child Safety:** Ensure no external links or inappropriate content can be accessed inadvertently. API responses (especially generative ones from Gemini) need careful handling and review.

## 5. Data Sources (Active)

*   **Quran Text/Translation/Transliteration/Audio:** `alquran.cloud` API (via `QuranApiDataSource`). Specific editions used are defined in `QuranApiDataSource`.
*   **Surah Introductions:** Google Gemini API (`gemini-1.5-flash` model via `GeminiSurahService`). Results are cached in Hive (`surahIntroductionCache`).
*   **AI Verse Translation:** Google Gemini API (`gemini-1.5-flash` model via `AiTranslationService`). Triggered by user swipe. (Using 1.5-flash due to potential availability issues with 2.5-preview).