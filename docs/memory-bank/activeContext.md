# Active Context

## Current Focus (as of commit 99eb9ae)

The focus has shifted to optimizing the web application's performance based on Lighthouse reports, particularly addressing initial load time and Core Web Vitals like Largest Contentful Paint (LCP).

## Recent Changes (leading up to commit 99eb9ae)

*   **Performance Analysis:** Reviewed Lighthouse and Chrome DevTools Performance reports for the Vercel deployment (`https://onlyquran420.vercel.app/`). Identified bottlenecks: LCP measurement error (NO_LCP), large initial JS bundle (`main.dart.js`), high JS execution time, and large asset downloads (Google CDN, fonts).
*   **Configuration Fixes:**
    *   Corrected `web/robots.txt` to allow crawlers. (Commit: `ee0e64e`)
    *   Added `lang="en"` attribute to `<html>` tag in `web/index.html`. (Commit: `ee0e64e`)
    *   Attempted to fix viewport accessibility (`user-scalable=no`) by modifying `web/index.html`, but the issue persists in Lighthouse reports, likely due to Flutter build overrides. (Commit: `ee0e64e`)
*   **Deferred Loading:** Implemented deferred loading (`deferred as` + `FutureBuilder`) for `QuranReaderScreen`, `SettingsScreen`, and `BadgesScreen` in `lib/features/navigation/app_router.dart` to potentially improve post-initial-load navigation. (Commit: `ee0e64e`)
*   **Font Preloading:** Added `<link rel="preload">` tags for primary web fonts in `web/index.html` to encourage earlier downloads. (Commit: `ee0e64e`)
*   **Renderer Testing:**
    *   Tested building with the HTML renderer by adding configuration to `web/index.html`. (Commit: `a274166`)
    *   Tested simplifying the initial route to isolate LCP issues. (Commit: `1fae73c`)
    *   Reverted initial route simplification. (Commit: `6041994`)
    *   Reverted HTML renderer configuration as it didn't resolve the LCP measurement error. (Commit: `99eb9ae`)

## Active Decisions

*   **Renderer:** Reverted to Flutter's default web renderer selection (likely CanvasKit for desktop) after testing showed the HTML renderer didn't resolve the LCP measurement issue in Lighthouse.
*   **Optimization Strategy:** Focused on configuration fixes, deferred loading for secondary routes, and font preloading. Further LCP optimization might require deeper investigation into Flutter Web's initial rendering or alternative approaches.

## Next Steps

1.  **Monitor Performance:** Observe the real-world performance and loading experience, despite the LCP measurement issue in Lighthouse.
2.  **Investigate Viewport Issue:** Research how to correctly configure the viewport in Flutter Web builds to allow user scaling and pass the accessibility check.
3.  **Further Bundle Size Reduction:** If initial load remains slow, investigate more aggressive code splitting or alternative asset loading strategies.
4.  **Continue Core Feature Development:** Resume work on core application features as planned.

## Current Considerations

1.  **LCP Measurement:** Acknowledging the difficulty in getting an accurate LCP score from Lighthouse for this Flutter Web app. Focus might shift to other metrics (FCP, SI, TTI if measurable) and user-perceived performance.
2.  **Accessibility:** The persistent `user-scalable=no` issue needs resolution.
3.  **CanvasKit vs HTML:** While reverted for now, the HTML renderer remains an option if specific performance characteristics or compatibility issues arise with CanvasKit.
