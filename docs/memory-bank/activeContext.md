# Active Context

## Current Focus (as of commit c99fc38)

The focus was on implementing the display of verse transliterations below the English translation in the Quran reader view, controlled by a user setting.

## Recent Changes (leading up to commit c99fc38)

*   **Transliteration Feature Implementation:**
    *   Updated `QuranApiDataSource` to fetch the `en.transliteration` edition from the `alquran.cloud` API alongside existing editions (Arabic, translation, audio).
    *   Confirmed `Verse` model already supported an optional `transliterationText` field and `fromJson` override.
    *   Confirmed `SharedPreferencesService` already had methods to get/set the `showTransliteration` preference.
    *   Confirmed `settings_providers.dart` already had a `showTransliterationProvider` (StateProvider) linked to SharedPreferences.
    *   Updated `VerseTile` widget to watch `showTransliterationProvider` and conditionally display the `verse.transliterationText` based on the provider's state.
    *   Confirmed `SettingsScreen` already had a `SwitchListTile` to control the `showTransliterationProvider`.
*   **(Previous) Web Performance Optimization:** Addressed Lighthouse issues, implemented deferred loading, font preloading, and tested web renderers. SEO/Best Practices improved, but LCP measurement issues persist. (Commits: `ee0e64e` to `99eb9ae`)

## Active Decisions

*   **Transliteration Source:** Using the `en.transliteration` edition from `alquran.cloud`.
*   **Transliteration Display:** Displayed below the English translation in `VerseTile`.
*   **Transliteration Control:** Visibility is controlled by a user setting (`showTransliterationProvider`), accessible via a switch in the `SettingsScreen`. Default is `true`.
*   **Missing Data Handling:** If transliteration text is null or empty (either from API or setting is off), nothing is displayed (no placeholder).

## Next Steps

1.  **Test Transliteration Feature:** Thoroughly test the display of transliterations, the settings toggle, persistence, and handling of potentially missing data across different platforms (Web, macOS, iOS).
2.  **Update Memory Bank:** Complete the documentation update for this feature in `progress.md`, `techContext.md`, and `systemPatterns.md`.
3.  **Address Known Issues:** Revisit persistent issues like LCP measurement, viewport accessibility, and potentially large bundle size.
4.  **Continue Core Feature Development:** Resume work on other planned features (e.g., pagination, audio improvements).

## Current Considerations

1.  **API Reliability:** Monitor the `alquran.cloud` API for consistent availability of the `en.transliteration` edition.
2.  **Transliteration Accuracy:** The quality/standard of the provided transliteration depends on the API source.
3.  **UI Layout:** Ensure the added transliteration text fits well within the `VerseTile` layout across different font sizes and screen widths.
