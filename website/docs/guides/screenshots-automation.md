# Screenshots Automation

This guide shows how to automate the process of taking screenshots and uploading them to Crowdin to provide context for translators or AI. It covers the necessary setup, how to use the Crowdin SDK, and a sample automation test.

## Prerequisites

Before you start, ensure you have:

- An iOS app project with UI Tests target
- Crowdin API access token with Screenshots scope
- Distribution hash from your Crowdin project
- Source language code configured in your Crowdin project

## Setting Up the Crowdin SDK

### Installation

First, add the screenshot feature to your UI Tests target. You can use either CocoaPods or Swift Package Manager.

#### CocoaPods

Add the following to your `Podfile`:

```ruby
target 'YourAppUITests' do
  pod 'CrowdinSDK/CrowdinTestScreenshots'
end
```

Then run:

```bash
pod install
```

Then add import to your tests source files:

```swift
import CrowdinSDK
```

#### Swift Package Manager

1. In Xcode, go to File > Add Packages
2. Add package with URL: `https://github.com/crowdin/mobile-sdk-ios`
3. Select "CrowdinTestScreenshots" product when adding the package
4. Add the package to your UI Tests target

Or add it to your Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/crowdin/mobile-sdk-ios.git", .upToNextMajor(from: "VERSION"))
],
targets: [
    .target(
        name: "YourUITests",
        dependencies: [
            .product(name: "CrowdinTestScreenshots", package: "CrowdinSDK")
        ]
    )
]
```

Then add imports in your tests source files:

```swift
import CrowdinSDK
import CrowdinTestScreenshots
```

### Key Configuration Options

To enable screenshots automation feature, you need to configure several components.

:::note Notes
- To enable screenshots tag you need to setup SDK in UI tests and in the app with the same localization. Localization should be in target language on crowdin.
- Before you can test your application with UI Test, you need to set it up with the localization you want to test.
:::

#### Main App Configuration

The main app must be configured with the same Crowdin configuration (distribution hash and source language) as the UI tests to ensure proper screenshot handling. If your app is configured with the SDK Controls button, it should be disabled during UI tests to prevent it from appearing in screenshots. See the [App UI Testing Mode Setup](#app-ui-testing-mode-setup) section for implementation details.

:::caution
If you want to have screenshots tagged for source language you need to ensure it's added to target languages.
:::

```swift
let crowdinProviderConfig = CrowdinProviderConfig(hashString: "{distribution_hash}",
                                                sourceLanguage: "{source_language}")

let crowdinSDKConfig = CrowdinSDKConfig.config()
    .with(crowdinProviderConfig: crowdinProviderConfig)
    .with(settingsEnabled: !isTesting) // Disable settings button during UI tests if it's enabled.

CrowdinSDK.startWithConfig(crowdinSDKConfig)
```

#### UI Tests Configuration

For UI testing it's recommended to use the access token authorization:

```swift
let crowdinProviderConfig = CrowdinProviderConfig(hashString: "{distribution_hash}",
                                                sourceLanguage: "{source_language}")

let crowdinSDKConfig = CrowdinSDKConfig.config()
    .with(crowdinProviderConfig: crowdinProviderConfig)
    .with(accessToken: "{access_token}") 
    .with(screenshotsEnabled: true)

CrowdinSDK.startWithConfigSync(crowdinSDKConfig)
```

#### App UI Testing Mode Setup

Add the `CROWDIN_UI_TESTING` launch argument to your tests so that you can set up your app for UI testing.  For example, if you use the SDK Controls button in debug - you can disable it and it won't be visible on your screenshots.

To add the launch argument you need to do the following in your tests:

```swift
let app = XCUIApplication()
app.launchArguments = ["CROWDIN_UI_TESTING"]
app.launch()
```

As you can see, the application has been launched through tests:

Using AppDelegate:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    if ProcessInfo.processInfo.arguments.contains("CROWDIN_UI_TESTING") {
        // Set up test data, mock services, etc.
        setupTestEnvironment()
    } else {
        // Normal app initialization
        setupNormalEnvironment()
    }
    return true
}
```

Using SceneDelegate:

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    if ProcessInfo.processInfo.arguments.contains("CROWDIN_UI_TESTING") {
        // Set up test data, mock services, etc.
        setupTestEnvironment(windowScene: windowScene)
    } else {
        // Normal app initialization
        setupNormalEnvironment(windowScene: windowScene)
    }
}
```

Required Parameters:

| Parameter            | Description                                                                  |
|----------------------|------------------------------------------------------------------------------|
| `accessToken`        | Crowdin API access token with Screenshots scope (required for UI tests only) |
| `screenshotsEnabled` | Boolean flag to enable screenshots feature (required for UI tests only)      |
| `distributionHash`   | Distribution Hash (required for both main app and UI tests)                  |
| `sourceLanguage`     | Source language code (required for both main app and UI tests)               |

## Capturing Screenshots with Crowdin SDK

The SDK provides a synchronous method for capturing screenshots:

```swift
CrowdinSDK.captureOrUpdateScreenshotSync(
    name: String,
    image: UIImage,
    application: XCUIApplication
) -> (result: ScreenshotUploadResult?, error: Error?)
```

Parameters:

| Parameter     | Description                          |
|---------------|--------------------------------------|
| `name`        | Unique identifier for the screenshot |
| `image`       | UIImage object of the screenshot     |
| `application` | XCUIApplication instance for context |

The method returns a tuple containing:

- `success` (ScreenshotUploadResult?): Uploading result: new or updated
- `error` (Error?): Second element containing error if operation failed

## Example Automation Test

Here's a complete example of implementing UI tests for automated screenshot capture:

```swift
import XCTest
import CrowdinSDK

final class ScreenshotsUITests: XCTestCase {
    
    private static let distributionHash = "{distribution_hash}"
    private static let sourceLanguage = "{source_language}"
    private static let accessToken = "{access_token}"
    
    override class func setUp() {
        // Configure SDK for UI Testing
        let crowdinProviderConfig = CrowdinProviderConfig(hashString: Self.distributionHash,
                                                        sourceLanguage: Self.sourceLanguage)
        
        let crowdinSDKConfig = CrowdinSDKConfig.config()
            .with(crowdinProviderConfig: crowdinProviderConfig)
            .with(accessToken: Self.accessToken)
            .with(screenshotsEnabled: true)
        
        CrowdinSDK.startWithConfigSync(crowdinSDKConfig)
    }
    
    override class func tearDown() {
        CrowdinSDK.stop()
        CrowdinSDK.deintegrate()
    }
    
    @MainActor
    func testScreenshots() throws {
        let app = XCUIApplication()
        // Recommended: Add launch argument to enable UI testing mode
        app.launchArguments = ["CROWDIN_UI_TESTING"]
        app.launch()
        
        // Capture main screen
        let result = CrowdinSDK.captureOrUpdateScreenshotSync(
            name: "MAIN_SCREEN", 
            image: XCUIScreen.main.screenshot().image,
            application: app
        )
        XCTAssertNil(result.error) // Verify no errors occurred
    }
}
```

### Example

Key implementation points from the example:

- **Testing Source Language Localization**:

  ```swift
  final class AppleRemindersUITestsCrowdinScreenhsotTests: XCTestCase {
      private static let distributionHash = "{distribution_hash}"
      private static let sourceLanguage = "{source_language}"
      private static let accessToken = "{access_token}"
      
      override class func setUp() {
          // Requires to start SDK before running testScreenshots as it needs to get all supported localizations from Crowdin.
          startSDK(localization: sourceLanguage)
      }
  
      class func startSDK(localization: String) {
          let crowdinProviderConfig = CrowdinProviderConfig(hashString: Self.distributionHash,
                                                            sourceLanguage: Self.sourceLanguage)
          
          let crowdinSDKConfig = CrowdinSDKConfig.config()
              .with(crowdinProviderConfig: crowdinProviderConfig)
              .with(accessToken: Self.accessToken)
              .with(screenshotsEnabled: true)
          
          CrowdinSDK.currentLocalization = localization
          
          CrowdinSDK.startWithConfigSync(crowdinSDKConfig)
      }
      
      @MainActor
      func testScreenshots() throws {
          XCTAssert(CrowdinSDK.inSDKLocalizations.count > 0, "At least one target language should be set up in Crowdin.")
          
          let app = XCUIApplication()
          // Pass selected localization in test to the app.
          app.launchArguments = ["UI_TESTING", "CROWDIN_LANGUAGE_CODE=\(Self.sourceLanguage)"]
          app.launch()
          
          let addListBtn = app.otherElements.buttons.element(matching: .button, identifier: "addListBtn")
          _ = app.waitForExistence(timeout: 5) // Timeout for app to start SDK and show UI.
          
          // MAIN SCREEN
          var result = CrowdinSDK.captureOrUpdateScreenshotSync(name: "MAIN_SCREEN_\(Self.sourceLanguage)", image: XCUIScreen.main.screenshot().image, application: app)
          XCTAssertNil(result.error)
      }
  }
  ```
  
  :::note
  For a more comprehensive example of screenshot automation with multiple localizations, you can refer to our [example UI tests](https://github.com/crowdin/mobile-sdk-ios/blob/xctests-support/Example/AppleRemindersUITests/AppleRemindersUITestsCrowdinScreenhsotTests.swift) and corresponding [app configuration](https://github.com/crowdin/mobile-sdk-ios/blob/xctests-support/Example/AppleReminders/SceneDelegate.swift).
  :::

- **App Configuration for Test Mode**:

  ```swift
  // In SceneDelegate
  let arguments = ProcessInfo.processInfo.arguments
  let isTesting = arguments.contains("UI_TESTING")
  
  if isTesting, let locale = arguments.first(where: { $0.contains("CROWDIN_LANGUAGE_CODE") })?.split(separator: "=").last.map({ String($0) }) {
      // Configure SDK for testing with specific locale
      let crowdinSDKConfig = CrowdinSDKConfig.config()
          .with(crowdinProviderConfig: crowdinProviderConfig)
          .with(accessToken: Self.accessToken)
          .with(screenshotsEnabled: true)
      
      CrowdinSDK.currentLocalization = locale
      
      CrowdinSDK.startWithConfig(crowdinSDKConfig) {
          // Initialize UI after SDK is configured
      }
  }
  ```

## Conclusion

Best Practices for Screenshot Automation:

1. Use descriptive screenshot names that reflect the screen or feature being captured
2. Always use UI testing mode launch argument to ensure consistent test environment
3. Set up appropriate test data in your app when CROWDIN_UI_TESTING argument is detected
4. Verify screenshot capture results using XCTAssertNil(result.error)
5. Clean up resources in tearDown method
6. When testing multiple localizations, ensure proper communication of locale between tests and app
7. Use localization-specific screenshot names for better organization

:::caution
Make sure your access token has the necessary permissions for screenshot management.
:::
