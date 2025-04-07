# System Patterns: Quran Adventures

## 1. System Architecture Overview

*   **Client-Side Application:** A Flutter application targeting macOS, Web, and iOS.
*   **Data Sources:** Primarily relies on external public APIs for Quran text, translations, transliterations, and audio. Includes local persistence for user progress, settings, and potentially cached data.
*   **Architecture Style:** Feature-First project structure with a focus on modularity and separation of concerns. Utilizes the Repository pattern for data abstraction.

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
    *   `Hive`: For structured user progress data and potentially offline caching (chosen for performance and ease of use over SQLite initially).
*   **Asynchronous Operations:** Standard Dart `Future`s and `Stream`s, managed within Riverpod providers.
*   **UI Components:** Emphasis on custom, reusable widgets to achieve the game-like aesthetic. Potential use of `CustomPainter` and integration with Rive/Lottie.
*   **Animation:** Combination of Flutter's built-in animation framework, `rive`, and `lottie` packages based on complexity requirements.

## 3. Component Relationships (Conceptual)

```mermaid
graph TD
    UI[UI Layer Widgets/Screens] --> State{State Management (Riverpod Providers)};
    State --> Repo[Repository Layer];
    Repo --> API[API Data Source (Dio)];
    Repo --> LocalDB[Local Data Source (Hive/Prefs)];
    
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

    FeatureReader --> State;
    FeatureGamify --> State;
    FeatureSettings --> State;
    FeatureNav --> Nav;
```

## 4. Error Handling

*   API errors handled within the Repository/Data Source layer, propagating meaningful errors or default states to the state management layer.
*   UI should display user-friendly error messages or fallback states.