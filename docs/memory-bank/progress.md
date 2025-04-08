# Progress

## What Works (with caveats)

### Core Functionality
- ✅ Project creation, editing, and deletion
- ✅ Task creation, editing, and deletion
- ✅ Task status management (complete/incomplete)
- ✅ Task due date management
- ✅ Project and task listing
- ✅ Dashboard with task counts and summaries

### Authentication
- ✅ Firebase Authentication integration
- ✅ Email/password authentication
- ✅ Anonymous usage support
- ✅ User-scoped data access
- ✅ macOS build command (`flutter build macos`) now succeeds (after entitlement workaround)

### Data Persistence
- ✅ Firestore integration for cloud storage
- ✅ User-scoped data collections
- ✅ Real-time data synchronization
- ✅ Offline data access (via Firestore caching)

### UI/UX
- ✅ Responsive design for mobile and desktop
- ✅ Dark/light theme support
- ✅ Animations for transitions and interactions
- ✅ Error handling and user feedback

### Web Platform
- ✅ Web version deployment (Vercel via GitHub static deployment)
- ✅ PWA support with offline capabilities
- ✅ Performance optimizations
- ✅ Service worker implementation
- ✅ Firebase Performance Monitoring

### macOS Platform
- ✅ App Store submission successful (after adding `LSApplicationCategoryType`)
- ✅ Basic, unsigned `.dmg` created (`Planner_Installer.dmg`) using `hdiutil`

## In Progress

### Flutter-Web Integration
- 🔄 Platform channels for JavaScript interop
- 🔄 Flutter integration with Performance Monitoring

### Offline Experience
- 🔄 Improved offline indicators
- 🔄 Background sync for offline actions

### Performance
- 🔄 Image optimization
- 🔄 Performance testing and optimization

## What's Left to Build

### Enhanced PWA Features
- ⬜ Custom installation prompt
- ⬜ Push notifications
- ⬜ App shortcuts for quick actions

### Advanced Features
- ⬜ Task filtering and sorting
- ⬜ Task search
- ⬜ Task attachments
- ⬜ Task comments
- ⬜ Task sharing
- ⬜ Project templates

### Analytics
- ⬜ User behavior tracking
- ⬜ Performance analytics integration
- ⬜ Crash reporting

### Testing
- ⬜ Comprehensive unit tests
- ⬜ Integration tests
- ⬜ Performance tests
- ⬜ Accessibility tests

## Known Issues

### macOS
- ⚠️ **Firebase Authentication (Sign-up/Sign-in) FAILS at runtime** in command-line builds (`flutter run`/`flutter build`). This is due to temporarily removing Network Client and Keychain Sharing entitlements from `.entitlements` files to bypass code signing errors during local CLI builds.
- ⚠️ **Workaround:** To test macOS auth, build and run directly from Xcode after configuring code signing (Personal Team or Developer ID).
- ⚠️ **Release Builds:** `Release.entitlements` appears correct, but proper code signing (Developer ID certificate) and notarization (app-specific password) must be configured before creating a distributable `.dmg` or App Store build that avoids Gatekeeper warnings.
- ⚠️ Basic `.dmg` created via `hdiutil` is unsigned and will trigger Gatekeeper warnings.

### Performance
- ⚠️ Global task views don't work efficiently (would require Firestore Collection Group queries)
- ⚠️ Initial load time could be improved

### Offline
- ⚠️ Limited feedback when offline actions are queued
- ⚠️ No visual indicator for offline state

### Web
- ⚠️ PWA installation experience needs improvement
- ⚠️ Some animations may cause performance issues on low-end devices
