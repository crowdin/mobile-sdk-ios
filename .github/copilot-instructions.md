# Crowdin iOS SDK - AI Coding Agent Guide

## Project Overview

This is an iOS/macOS/tvOS/watchOS SDK for delivering Over-The-Air (OTA) localization updates from Crowdin. The SDK swizzles Bundle methods to intercept localization lookups and provide translations from remote storage.

## Architecture

### Core Components

1. **CrowdinSDK** (`Sources/CrowdinSDK/CrowdinSDK/CrowdinSDK.swift`) - Main singleton entry point
   - Initializes via `startWithConfig(_:completion:)` with `CrowdinSDKConfig`
   - Uses method swizzling on `Bundle`, `UIButton`, `UILabel` to intercept localization calls
   - Features are modular and loaded via Objective-C runtime selectors

2. **Provider Pattern** - Two-layer storage architecture:
   - `LocalizationProvider`: Coordinates between local and remote storage
   - `LocalLocalizationStorage`: Caches translations in Documents folder
   - `RemoteLocalizationStorage`: Protocol for fetching from Crowdin CDN
   - Primary implementation: `CrowdinRemoteLocalizationStorage` in `Sources/CrowdinSDK/Providers/Crowdin/`

3. **Modular Features** (optional subspecs):
   - `Screenshots`: Upload screenshots with tagged strings
   - `RealtimeUpdate`: WebSocket-based live preview
   - `IntervalUpdate`: Periodic translation refresh
   - `Settings`: Debug UI controls
   - `LoginFeature`: OAuth authentication

### Key Patterns

**Configuration Builder Pattern**:
```swift
let config = CrowdinSDKConfig.config()
    .with(crowdinProviderConfig: CrowdinProviderConfig(hashString: "...", sourceLanguage: "en"))
    .with(screenshotsEnabled: true)
    .with(realtimeUpdatesEnabled: true)
CrowdinSDK.startWithConfig(config, completion: {})
```

**Method Swizzling**: Bundle localization methods are swizzled in `Bundle.swizzle()`. Always use `swizzled_` prefixed methods when calling original implementations. Check `isSwizzled` flag before swizzling/unswizzling.

**Feature Detection**: Features use runtime selector checking:
```swift
if CrowdinSDK.responds(to: Selectors.initializeScreenshotFeature.rawValue) {
    CrowdinSDK.perform(Selectors.initializeScreenshotFeature.rawValue)
}
```

## Build & Test Workflow

### Package Managers
- **Swift Package Manager**: Primary build system (builds all platforms)
- **CocoaPods**: Used by Example apps and Tests (`pod_install.sh` installs all Podfiles)

### Running Tests
```bash
# Install test dependencies
cd Tests && pod install

# Run tests via xcodebuild (CI approach)
xcodebuild test \
  -workspace ./Tests.xcworkspace \
  -scheme TestsTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -enableCodeCoverage YES
```

Tests are in two locations:
- `Sources/Tests/` - Embedded test specs for Core/API/Provider
- `Tests/UnitTests/` - Full integration tests

### Code Quality
- **SwiftLint**: Enforced via pre-commit hook (`pre-commit`) and CI
  - Config: `.swiftlint.yml`
  - Run manually: `./run_swiftlint.sh`
  - Only lints `Sources/` directory
- **Danger**: PR review automation (`Dangerfile.swift`) - warns on large PRs, runs SwiftLint

### Platform Testing
SDK supports iOS 12+, macOS 10.13+, tvOS 12+, watchOS 5+. Always test cross-platform changes:
```bash
xcodebuild build -scheme CrowdinSDK -destination 'platform=macOS'
xcodebuild build -scheme CrowdinSDK -destination 'platform=tvOS Simulator,name=Apple TV'
```

## Development Conventions

### File Organization
- `Sources/CrowdinSDK/CrowdinSDK/` - Core SDK (no external dependencies)
- `Sources/CrowdinSDK/Features/` - Optional features (each is a podspec subspec)
- `Sources/CrowdinSDK/Providers/Crowdin/` - Crowdin-specific implementation
- Feature extensions use pattern: `CrowdinSDK+FeatureName.swift`

### Objective-C Interoperability
Classes/properties exposed to ObjC use `@objcMembers`. See `ObjCExample/` for usage patterns.

### Multi-platform Code
```swift
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
```

### Testing Patterns
- Always call `CrowdinSDK.deintegrate()` in `tearDown()` to clean Documents folder
- Test swizzling reentrancy: `BundleSwizzleReentrancyTests.swift` shows proper patterns
- Mock remote storage for offline tests

## Common Tasks

### Adding a New Feature
1. Create directory in `Sources/CrowdinSDK/Features/NewFeature/`
2. Add extension: `Sources/CrowdinSDK/Features/NewFeature/Extensions/CrowdinSDK+NewFeature.swift`
3. Implement selector in extension (e.g., `@objc class func initializeNewFeature()`)
4. Add selector to `CrowdinSDK.Selectors` enum
5. Add subspec to `CrowdinSDK.podspec`
6. Call from `initializeLib()` using selector pattern

### Modifying Swizzling
- Swizzle state is tracked per-class (e.g., `Bundle.isSwizzled`)
- Always check state before swizzling/unswizzling
- Original methods prefixed with `swizzled_`
- See `BundleSwizzleReentrancyTests` for edge cases

### Documentation
Docs are Docusaurus-based in `website/`:
```bash
cd website && npm install && npm start
```

## Critical Details

- **Distribution Hash**: Primary config parameter (`CrowdinProviderConfig.hashString`) - identifies the CDN distribution
- **Localization Priority**: Remote (Crowdin) → Local Cache → Bundle
- **File Storage**: Uses `CrowdinFolder` in app Documents directory
- **Observer Pattern**: Download handlers via `LocalizationUpdateObserver` (supports multiple subscribers)
- **Conventional Commits**: Required for PR titles (enforced by `lint-pr-title.yml`)
