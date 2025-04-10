# Active Context

## Current Focus (as of commit 770bd6c)

The primary focus at this point in the history was likely stabilizing and configuring the Vercel deployment process, specifically aligning the build artifacts (`build/web`) with the Vercel dashboard settings (Framework: Other, Output Directory: `build/web`, Build Command: `./build.sh`).

## Recent Changes (leading up to commit 770bd6c)

*   **Vercel Deployment Adjustments:** Iterations were made to the Vercel deployment configuration. This commit (`770bd6c`) specifically aimed to fix the alignment between the build output and the Vercel dashboard configuration, likely involving adjustments to `vercel.json` or the build process itself (potentially `build.sh`, although the exact changes in that commit need inspection if details are required).
*   *(Previous history before this commit is not detailed here but involved initial project setup and feature development).*

## Active Decisions (Likely state at commit 770bd6c)

*   **Vercel Deployment Strategy:** The project was likely using or moving towards a strategy where the Flutter web build is performed locally or via a script (`build.sh`), and the resulting `build/web` directory is specified as the Output Directory in Vercel dashboard settings.
*   **Data Source:** Using local JSON (`assets/data/quran_arabic_text.json`) for Quran text.

## Next Steps (Estimated from commit 770bd6c)

1.  **Test Vercel Deployment:** Verify that the deployment configured up to commit `770bd6c` works correctly.
2.  **Continue Core Feature Development:** Resume work on core Quran reader features or other planned application components.
3.  **Refine Build/Deployment:** Further optimize or stabilize the build and deployment process if needed.

## Current Considerations (Estimated from commit 770bd6c)

1.  **Vercel Build Process:** Is the current `build.sh` (if used) and dashboard configuration the optimal long-term approach?
2.  **State Management:** Review and refine the use of Riverpod for state management as complexity grows.
3.  **Data Persistence:** Evaluate if local JSON is sufficient or if a more robust local or cloud database solution (like Drift, Hive, or Firestore) is needed for future features (e.g., user progress, bookmarks).

*(Note: This context is reconstructed based on the commit history reset. Details about specific implementations like Firebase, advanced web features, or macOS builds described previously are no longer applicable to the current HEAD commit `770bd6c`)*
