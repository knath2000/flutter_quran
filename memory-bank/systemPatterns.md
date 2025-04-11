# System Patterns: Quran Adventures

## 1. System Architecture Overview

*   **Client-Side Application:** A Flutter application targeting macOS, Web, and iOS.
*   **Data Sources:** Relies on external public APIs: `alquran.cloud` (via `QuranApiDataSource`) for Quran text/audio/etc., and Google Gemini API (via `GeminiSurahService`) for Surah introductions.
*   **Architecture Style:** Feature-First project structure with a focus on modularity and separation of concerns. Utilizes the Repository pattern for `alquran.cloud` data abstraction. Gemini calls are managed within the `surah_details_provider`.

## 2. Key Technical Decisions & Patterns

*   **State Management:** Riverpod 2.0
    *   *Rationale:* Compile safety, testability, flexibility for managing complex UI, audio, and gamification states. Scales well.
*   **Navigation:** GoRouter
    *   *Rationale:* Declarative routing, handles deep linking, simplifies complex navigation flows.
*   **Project Structure:** Feature-First
    *   *Rationale:* Enhances modularity, makes features self-contained, easier navigation and scaling for this app type. (e.g., `lib/features/quran_reader/`, `lib/features/gamification/`).
*   **Data Fetching:** Repository Pattern
    *   *Rationale:* Decouples data sources (API, local cache) from the application logic (providers/controllers). Allows easier swapping or combining of data sources.
*   **Data Persistence:**
    *   `shared_preferences`: For simple key-value settings.
    *   `Hive`: For structured user progress (`userProgressBox`), verse caching (`quranVerseCache`), and Surah introduction caching (`surahIntroductionCache`).
*   **Asynchronous Operations:** Standard Dart `Future`s and `Stream`s, managed within Riverpod providers.
*   **UI Components:** Emphasis on custom, reusable widgets to achieve the game-like aesthetic. Potential use of `CustomPainter` and integration with Rive/Lottie.
*   **Animation:** Combination of Flutter's built-in animation framework, `rive`, and `lottie` packages based on complexity requirements.

## 3. Component Relationships (Conceptual)

```mermaid
graph TD
    UI[UI Layer Widgets/Screens] --> State{State Management (Riverpod Providers)};
    
    %% Data Flow for Quran Text/Audio etc.
    State -- Request Surah Details --> Repo[Quran Repository];
    Repo -- Fetch Verses --> API[alquran.cloud API (via Dio)];
    Repo -- Cache Verses --> VerseCache[Hive (Verse Cache)];
    Repo -- Read Cache --> VerseCache;
    API -- Response --> Repo;
    VerseCache -- Cached Verses --> Repo;
    Repo -- Verse Data --> State;

    %% Data Flow for Introductions (Managed in Provider)
    State -- Request Intro --> Gemini[Gemini API Service];
    State -- Cache Intro --> IntroCache[Hive (Intro Cache)];
    State -- Read Cache --> IntroCache;
    Gemini -- Generated Intro --> State;
    IntroCache -- Cached Intro --> State;

    %% Other Interactions
    State -- User Progress --> UserProgressCache[Hive (User Progress)];
    State -- Settings --> Prefs[SharedPreferences];
    UI -- Nav Events --> Nav[Navigation (GoRouter)];
    UI -- Audio Events --> Audio[Audio Service (just_audio)];
    State -- Updates --> Audio;
    State -- Updates --> UI;

    subgraph Features
        direction LR
        FeatureReader[Quran Reader Feature]
        FeatureGamify[Gamification Feature]
        FeatureSettings[Settings Feature]
        FeatureNav[Navigation Feature]
    end

    UI --> FeatureReader;
    UI --> FeatureGamify;
    UI --> FeatureSettings;
    UI --> FeatureNav;

    FeatureReader --> State; %% Connects to surah_details_provider etc.
    FeatureGamify --> State; %% Connects to user_progress_provider etc.
    FeatureSettings --> State; %% Connects to settings_provider etc.
    FeatureNav --> Nav;
```

## 4. Error Handling

*   `alquran.cloud` API errors handled within the Repository/Data Source layer, propagating errors to the state management layer (`surah_details_provider`).
*   Google Gemini API errors handled directly within the `surah_details_provider`, potentially falling back to a default introduction text.
*   UI should display user-friendly error messages or fallback states based on the `AsyncValue` state from providers.