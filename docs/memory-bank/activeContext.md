# Active Context

## Current Focus (as of commit 02a2c77)

The focus was on implementing the UI structure for a Surah introduction/summary section at the top of the `QuranReaderScreen`, mirroring a provided example and using placeholder text for now.

## Recent Changes (leading up to commit 02a2c77)

*   **Surah Introduction UI:**
    *   Updated `SurahInfo` model (`lib/core/models/surah_info.dart`) to include an optional `introduction` field.
    *   Created a new `SurahIntroductionCard` widget (`lib/features/quran_reader/presentation/widgets/surah_introduction_card.dart`) using `flutter_hooks` for state management (expansion toggle).
        *   Displays Surah name, truncated introduction text, and a "View Full Content" / "Show Less" button.
        *   Uses placeholder text for the introduction content.
        *   Styled to resemble the provided screenshot example.
    *   Added `flutter_hooks` dependency to `pubspec.yaml` and ran `flutter pub get`.
    *   Integrated `SurahIntroductionCard` into `QuranReaderScreen`, placing it above the verse list. It fetches the relevant `SurahInfo` from the `surahListProvider` to display the title.
*   **(Previous) Transliteration Feature:** Implemented display of verse transliterations below translations, controlled by a user setting. Updated API calls and UI accordingly. (Commit: `c99fc38`)
*   **(Previous) Web Performance Optimization:** Addressed Lighthouse issues, implemented deferred loading, font preloading, etc. (Commits: `ee0e64e` to `99eb9ae`)

## Active Decisions

*   **Surah Introduction Data:** Using placeholder text within the `SurahIntroductionCard` widget for now. Actual data fetching (from API or local file) is deferred.
*   **UI Placement:** The introduction card is placed at the top of the `QuranReaderScreen`'s body content.
*   **Expansion:** The card includes basic expand/collapse functionality managed by internal state (`useState`).

## Next Steps

1.  **Test Surah Introduction UI:** Verify the card appears correctly, uses placeholder text, expands/collapses, and styling is acceptable across different screen sizes.
2.  **Implement Actual Data Fetching:** Plan and implement the logic to fetch real Surah introduction data (e.g., from an API endpoint or the `surahdesc.rtf` file mentioned previously) and replace the placeholder text.
3.  **Update Memory Bank:** Complete the documentation update for this UI implementation in `progress.md` and `systemPatterns.md`.
4.  **Address Known Issues:** Revisit persistent issues like LCP measurement, viewport accessibility, etc.
5.  **Continue Core Feature Development:** Resume work on other planned features.

## Current Considerations

*   **Data Source for Introduction:** Need to finalize the source (API vs. local file parsing) for the actual introduction text.
*   **UI Styling:** Further refinement of the `SurahIntroductionCard` styling might be needed to perfectly match the example or theme.
*   **State Management:** The simple `useState` for expansion is suitable for now, but could be refactored if more complex interactions are needed later.
