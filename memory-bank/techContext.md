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
*   **API Dependencies:** Reliant on external public APIs for core content. Need robust error handling, caching, and potential fallbacks. API rate limits or changes could impact the app.
*   **Asset Management:** Requires management of potentially large audio files and animation assets (Rive/Lottie files). Consider asset bundling strategies or on-demand downloading/caching.
*   **Child Safety:** Ensure no external links or inappropriate content can be accessed inadvertently. API responses need careful handling.

## 5. Data Sources (Planned)

*   **Quran Text/Translation/Transliteration:** Public APIs (e.g., `alquran.cloud`, `quran.com API`, `fawazahmed0/quran-api`). Specific API and translation/reciter choices TBD after vetting.
*   **Audio:** Public APIs or potentially separate hosting/bundling if specific child-friendly reciters aren't available via primary APIs.