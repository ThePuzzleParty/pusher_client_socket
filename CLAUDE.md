# PuzzleParty Flutter Mobile App - Claude Context

## ⚠️ CRITICAL: Git Workflow Rule
**BEFORE making ANY code changes, ALWAYS:**
1. Check current branch: `git branch --show-current`
2. If on `develop` → Create feature branch: `git checkout -b feature/[name]`
3. If on feature branch → OK to proceed
4. **NEVER commit directly to `develop` branch!**

See "Development Workflow for Claude" section below for complete instructions.

---

## Project Overview
Flutter mobile app for iOS and Android that connects to the PuzzleParty Laravel API. Users track daily puzzle scores, create and join parties with friends, and compete on adaptive scoreboards. The app features offline-first architecture with multi-device synchronization.

## Key Information for Claude
- **Framework:** Flutter/Dart with adaptive UI for phones and tablets
- **State Management:** Provider pattern with ChangeNotifier
- **API Client:** Dio for HTTP requests with interceptors
- **Local Storage:** SQLite for offline-first architecture
- **Authentication:** Secure storage with multi-device support
- **Target Platforms:** iOS and Android (desktop planned for future)
- **Repository:** https://github.com/ThePuzzleParty/puzzleparty-mobile

## Architecture Guidelines
- **Adaptive UI:** Responsive layouts for phones (< 768px) and tablets (≥ 768px)
- **Offline-First:** All data stored locally with background sync
- **Contract-First:** Always check `../puzzleparty-docs/` for specifications
- **Environment-Aware:** Different configurations for dev/staging/production
- **Cross-Platform:** Consistent experience across iOS and Android
- **Accessibility:** Support for screen readers and accessibility features

## Code Conventions
- **Models:** JSON serializable with Equatable for value comparison
- **Services:** Repository pattern for data access abstraction
- **Widgets:** Adaptive components that respond to screen size and platform
- **Screens:** Separate implementations for phone and tablet when needed
- **State Management:** Provider pattern with clear separation of concerns
- **Testing:** Unit tests for business logic, widget tests for UI components
- **File Organization:** Feature-based folder structure

## Project Structure
```
lib/
├── core/
│   ├── services/          # API, auth, sync, sharing services
│   ├── utils/             # Utilities, helpers, constants
│   └── config/            # Environment and app configuration
├── data/
│   ├── models/            # Data models with JSON serialization
│   ├── repositories/      # Data access layer
│   └── database/          # Local SQLite database
├── presentation/
│   ├── adaptive/          # Responsive UI components
│   ├── screens/           # App screens and pages
│   ├── widgets/           # Reusable UI components
│   └── providers/         # State management providers
└── main.dart              # App entry point
```

## Key Features
- **Multi-Device Authentication:** Secure token storage and device management
- **Puzzle Sharing Integration:** iOS/Android sharing sheet integration
- **Adaptive Scoreboards:** Different layouts optimized for phones vs tablets
- **Offline Sync:** Submit puzzles offline, sync when connected
- **Real-Time Updates:** Live scoreboard updates across devices
- **Party Management:** Create, join, and manage puzzle parties
- **Cross-Device Continuity:** Seamless experience across multiple devices

## API Integration
- **Base URL:** Environment-specific (development/staging/production)
- **Authentication:** Bearer tokens with automatic refresh
- **Versioning:** API version headers for compatibility checking
- **Error Handling:** Graceful fallbacks and user-friendly error messages
- **Sync Strategy:** Background sync with conflict resolution
- **Offline Support:** Local data storage with sync queue

## Mobile-Specific Considerations
- **Screen Sizes:** Support from iPhone SE to iPad Pro
- **Platform Integration:** Native iOS and Android sharing functionality
- **Background Processing:** Sync data when app becomes active
- **Battery Optimization:** Efficient background tasks and network usage
- **Data Usage:** Minimize bandwidth with smart sync strategies
- **Security:** Secure storage using platform keychain/keystore

## Important Files to Reference
- `../puzzleparty-docs/specs/frontend/flutter-detailed-spec.md` - Complete implementation spec
- `../puzzleparty-docs/specs/shared/main-specification.md` - Overall project architecture
- `../puzzleparty-docs/contracts/api/openapi.yaml` - API contracts
- `lib/core/config/environment.dart` - Environment configuration
- `lib/core/utils/mobile_breakpoints.dart` - Responsive breakpoints

## 🚨 Development Workflow for Claude

**CRITICAL: Always Use Feature Branches - NEVER Commit Directly to Develop!**

### ⚠️ MANDATORY Pre-Work Checklist (Run BEFORE making any code changes):

1. **Check current branch:**
   ```bash
   git branch --show-current
   ```
   - If on `develop` → STOP! Create a feature branch first
   - If on a feature branch → OK to proceed

2. **Create new feature branch from develop:**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/[descriptive-name]
   ```

3. **Verify you're on the feature branch:**
   ```bash
   git branch --show-current
   # Should show: feature/[descriptive-name]
   ```

### Required Workflow:
```bash
# STEP 1: ALWAYS create feature branch FIRST (before ANY edits)
git checkout develop
git pull origin develop
git checkout -b feature/[descriptive-name]

# STEP 2: Make your changes (Read, Edit, Write files)

# STEP 3: Test and analyze
flutter test
flutter analyze

# STEP 4: Commit to feature branch
git add .
git commit -m "[type]: [description]"

# STEP 5: Push feature branch
git push origin feature/[descriptive-name]

# STEP 6: Create PR targeting develop branch
```

### Branch Naming Convention:
- `feature/adaptive-ui-framework`
- `feature/multi-device-authentication`
- `feature/puzzle-sharing-integration`
- `feature/offline-sync-system`
- `feature/scoreboard-screens`
- `feature/party-management-ui`
- `fix/tablet-layout-bug`
- `refactor/state-management-optimization`

### Commit Message Convention:
Use conventional commits:
- `feat: add adaptive navigation for phones and tablets`
- `fix: resolve sharing intent handling on Android`
- `test: add widget tests for scoreboard components`
- `refactor: optimize sync service performance`
- `style: update theme and color scheme`

### Never Do This:
```bash
git checkout develop  # ❌ Don't commit directly to develop
git commit -m "changes"  # ❌ Don't commit to develop
git push origin develop  # ❌ Never push directly to develop
```

## Testing Requirements
- **Unit Tests:** All business logic, services, and repositories
- **Widget Tests:** All custom widgets and screens
- **Integration Tests:** Complete user flows and API integration
- **Golden Tests:** Visual regression testing for UI components
- **Test Coverage:** Aim for 70%+ coverage
- **Mock Services:** Use mockito for testing external dependencies

## Adaptive UI Guidelines
- **Breakpoints:** < 768px (phone), ≥ 768px (tablet)
- **Navigation:** Bottom navigation (phone) vs navigation rail (tablet)
- **Layout:** Single column (phone) vs multi-column (tablet)
- **Typography:** Responsive text scaling
- **Touch Targets:** Minimum 44px touch targets
- **Spacing:** Adaptive padding and margins based on screen size

## State Management Pattern
- **Providers:** Use ChangeNotifier for state management
- **Repository Pattern:** Abstract data access behind repositories
- **Separation of Concerns:** Clear separation between UI and business logic
- **Data Flow:** Unidirectional data flow with providers
- **Error Handling:** Centralized error handling with user feedback

## Environment Configuration
```dart
// Environment-specific configurations
enum Environment { development, staging, production }

// Development: http://localhost:8000/api/v1
// Staging: https://api-staging.puzzleparty.app/v1
// Production: https://api.puzzleparty.app/v1
```

## Build Commands
```bash
# Development (local API)
flutter run --dart-define=ENVIRONMENT=development

# Staging builds
flutter build apk --release --dart-define=ENVIRONMENT=staging
flutter build ios --release --dart-define=ENVIRONMENT=staging

# Production builds
flutter build apk --release --dart-define=ENVIRONMENT=production
flutter build ios --release --dart-define=ENVIRONMENT=production
```

## Current Implementation Status
Track progress as features are implemented:

### Authentication & User Management
- [ ] Multi-device authentication service
- [ ] Secure token storage (iOS Keychain, Android Keystore)
- [ ] Device registration and management
- [ ] User profile management
- [ ] Authentication screens (login, register, profile)

### Adaptive UI Framework
- [ ] Mobile breakpoints and screen type detection
- [ ] Adaptive scaffold with responsive navigation
- [ ] Adaptive content layouts
- [ ] Phone-optimized screens and widgets
- [ ] Tablet-optimized screens and widgets

### API Integration
- [ ] API service with environment configuration
- [ ] Authentication interceptors
- [ ] Error handling and retry logic
- [ ] Offline queue management
- [ ] Sync service with conflict resolution

### Data Layer
- [ ] Local SQLite database setup
- [ ] Data models with JSON serialization
- [ ] Repository implementations
- [ ] Database migration system
- [ ] Data synchronization logic

### Puzzle Integration
- [ ] Sharing intent handling (iOS/Android)
- [ ] Puzzle text parsing and validation
- [ ] Puzzle submission to multiple parties
- [ ] Offline puzzle storage and sync
- [ ] Duplicate detection and handling

### Scoreboard & Party Features
- [ ] Adaptive scoreboard screens
- [ ] Real-time score updates
- [ ] Party creation and management UI
- [ ] Party member invitation system
- [ ] Party chat functionality

### Advanced Features
- [ ] Background sync (future: consider flutter_background_service)
- [ ] Push notifications
- [ ] App state restoration
- [ ] Performance monitoring
- [ ] Crash reporting and analytics

## Key Dependencies
```yaml
dependencies:
  dio: ^5.3.2                    # HTTP client
  flutter_secure_storage: ^9.0.0 # Secure token storage
  provider: ^6.1.1              # State management
  sqflite: ^2.3.0               # Local database
  shared_preferences: ^2.2.2     # App settings
  go_router: ^12.1.1            # Navigation
  device_info_plus: ^9.1.0      # Device information
  connectivity_plus: ^5.0.1     # Network status
  share_plus: ^7.2.1            # Share functionality

dev_dependencies:
  mockito: ^5.4.2               # Mocking for tests
  build_runner: ^2.4.7          # Code generation
  json_serializable: ^6.7.1     # JSON serialization
```

**Note:** `workmanager` and `receive_sharing_intent` were removed as they were outdated and blocking dependency updates. Puzzle sharing is now handled via clipboard auto-detection and manual text entry.

## Performance Considerations
- **Memory Management:** Dispose controllers and streams properly
- **Image Optimization:** Use cached network images with proper sizing
- **List Performance:** Use ListView.builder for large lists
- **State Updates:** Minimize rebuild frequency with targeted providers
- **Database Optimization:** Use proper indexes and efficient queries
- **Network Efficiency:** Batch API calls and implement smart sync

## Security Best Practices
- **Token Storage:** Use secure storage for authentication tokens
- **Input Validation:** Validate all user inputs before API calls
- **Error Messages:** Don't expose sensitive information in errors
- **Network Security:** Use certificate pinning for production
- **Data Encryption:** Encrypt sensitive local data
- **Permission Management:** Request minimal necessary permissions

## Platform-Specific Features
### iOS
- **Cupertino Widgets:** Use for iOS-specific UI elements
- **Haptic Feedback:** Implement appropriate haptic responses
- **iOS Sharing:** Native sharing sheet integration
- **App Transport Security:** Configure for API access

### Android
- **Material Design:** Follow Material Design 3 guidelines
- **Android Intents:** Handle puzzle sharing intents
- **Adaptive Icons:** Implement adaptive app icons
- **Background Tasks:** Handle Android background limitations

## When Starting New Features
1. **Review specifications** in puzzleparty-docs repository
2. **Create feature branch** with descriptive name
3. **Plan adaptive UI** for both phone and tablet layouts
4. **Write tests first** when possible (TDD approach)
5. **Implement feature** following Flutter best practices
6. **Test on both platforms** (iOS and Android)
7. **Run full test suite** before committing
8. **Update this file** with implementation status
9. **Create PR** with screenshots and testing notes

## Helpful Commands
```bash
# Testing and Analysis
flutter test
flutter analyze
flutter test --coverage

# Code Generation
flutter packages pub run build_runner build
flutter packages pub run build_runner watch

# Platform-specific builds
flutter build apk --debug    # Android debug
flutter build ios --debug    # iOS debug
flutter build appbundle     # Android App Bundle

# Development helpers
flutter doctor
flutter devices
flutter logs
flutter clean && flutter pub get
```

## Debugging and Troubleshooting
- **Flutter Inspector:** Use for widget tree debugging
- **Network Debugging:** Monitor API calls with dio interceptors
- **State Debugging:** Use provider devtools for state inspection
- **Performance Profiling:** Use Flutter performance tools
- **Device Testing:** Test on real devices, not just simulators

Remember: This project follows the detailed specifications in the puzzleparty-docs repository. Always reference those documents for complete requirements and implementation details. The app must work seamlessly across phone and tablet form factors while maintaining offline capability and multi-device synchronization.
