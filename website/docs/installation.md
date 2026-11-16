---
description: Add the Crowdin iOS SDK to your project using Swift Package Manager. Learn how to migrate from CocoaPods, and about the requirements and dependencies.
---

# Installation

## Swift Package Manager

Swift Package Manager (SPM) is the recommended way to install the Crowdin iOS SDK. It is integrated with Xcode and the Swift compiler, so there is nothing to install locally.

To add `CrowdinSDK` to your project using SPM:

1. In Xcode, select File > Add Package Dependencies...
2. Enter the package repository URL: `https://github.com/crowdin/mobile-sdk-ios.git`
3. Select the version you want to use (latest release recommended)
4. Click Add Package and add the `CrowdinSDK` product to your app target

Alternatively, you can add it directly to your Package.swift:

```swift title="Package.swift"
dependencies: [
    .package(url: "https://github.com/crowdin/mobile-sdk-ios.git", from: "1.16.1")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "CrowdinSDK", package: "mobile-sdk-ios")
        ]
    )
]
```

:::tip
For better version control, you can specify an exact version or version range:

```swift
.package(url: "https://github.com/crowdin/mobile-sdk-ios.git", .upToNextMajor(from: "1.16.1"))
```
:::

The package provides two products:

- `CrowdinSDK` - the SDK itself, including Real-Time Preview, Screenshots, and SDK Controls. No additional setup is needed to enable these features.
- `CrowdinXCTestScreenshots` - screenshots automation for UI tests. See the [Screenshots Automation](/guides/screenshots-automation) guide.

## Migrating from CocoaPods

:::warning CocoaPods is deprecated
CocoaPods Trunk becomes read-only on December 2, 2026, so new SDK releases will not be published to CocoaPods. Versions already published there stay available for download, but we recommend moving to Swift Package Manager to receive updates.
:::

To migrate an existing project:

1. Remove `pod 'CrowdinSDK'` and every `pod 'CrowdinSDK/...'` subspec line from your `Podfile`. If you added the `post_install` script for App Extensions, remove it as well.
2. Run `pod install` to update your workspace. If `CrowdinSDK` was the last pod in the project, run `pod deintegrate` instead and continue with the `.xcodeproj` rather than the `.xcworkspace`.
3. Add the package as described in the [Swift Package Manager](#swift-package-manager) section.
4. If you used the `CrowdinSDK/CrowdinXCTestScreenshots` subspec in your UI tests target, add the `CrowdinXCTestScreenshots` product to that target instead.
5. Build the project. Your code doesn't need any changes: the module is still named `CrowdinSDK`, so existing `import CrowdinSDK` statements keep working.

CocoaPods subspecs (`Screenshots`, `RealtimeUpdate`, `LoginFeature`, `Settings`, and others) don't exist in SPM. Their functionality is part of the single `CrowdinSDK` product, so you only need to enable the features in the SDK configuration. See [SDK Structure](/guides/sdk-structure).

## CocoaPods (deprecated)

:::caution
This installation method is deprecated and will not receive new releases after CocoaPods Trunk becomes read-only. Use [Swift Package Manager](#swift-package-manager) for new projects.
:::

1. CocoaPods

   To install the Crowdin iOS SDK via [CocoaPods](https://cocoapods.org), make sure you have CocoaPods installed locally. If you don't have it, follow the official [installation guide](https://guides.cocoapods.org/using/getting-started.html) first.

   Then add the following line to your `Podfile`:

   ```ruby title="Podfile"
   pod 'CrowdinSDK'
   ```

2. CocoaPods spec repository:

   ```ruby
   target 'MyApp' do
     pod 'CrowdinSDK'
   end
   ```

   :::tip
   You can also specify the exact branch of the Crowdin iOS SDK in your `Podfile`:

   ```ruby
   pod 'CrowdinSDK', :git => 'https://github.com/crowdin/mobile-sdk-ios.git', :branch => 'dev'
   ```
   :::

3. Working with App Extensions:

   After running `pod install`, you might experience some build issues in case your application embeds target extensions.

   Example error:

   > 'shared' (Swift) / 'sharedApplication' (Objective-C) is unavailable: not available on iOS (App Extension) - Use view controller based solutions where appropriate instead.

   In this scenario, you'll need to add a `post_install` script to your `Podfile`:

    ```ruby
    post_install do |installer|

      extension_api_exclude_pods = ['CrowdinSDK']

      installer.pods_project.targets.each do |target|

          # the Pods contained into the `extension_api_exclude_pods` array
          # have to get the value (APPLICATION_EXTENSION_API_ONLY) set to NO
          # in order to work with service extensions

          if extension_api_exclude_pods.include? target.name
            target.build_configurations.each do |config|
              config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
            end
          end
        end
    end
    ```

   Then run `pod install` again to fix it.

After you've added `CrowdinSDK` to your `Podfile`, run `pod install` in your project directory, open `App.xcworkspace` and build it.

## Requirements

* Xcode 15.0+
* Swift 5.0+
* iOS 15.0+
* macOS 12.0+
* tvOS 15.0+
* watchOS 9.0+

:::info
R-Swift applications are also supported by the Crowdin iOS SDK.
:::

## Dependencies

* [Starscream](https://github.com/daltoniam/Starscream) (~> 4.0.4) - WebSockets in Swift for iOS and macOS
* [BaseAPI](https://github.com/serhii-londar/BaseAPI.git) (~> 0.2.2)

## See also

- [Setup](setup)
- [Screenshots](advanced-features/screenshots)
- [Real-Time Preview](advanced-features/real-time-preview)
