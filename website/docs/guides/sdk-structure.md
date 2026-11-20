---
description: Explore the Crowdin iOS SDK structure - Core, CrowdinProvider, Screenshots, RealtimeUpdate, LoginFeature, and other submodules.
---

# SDK Structure

## Submodules

CrowdinSDK is divided into separate parts. If you install the SDK via Swift Package Manager, all of them are included in the `CrowdinSDK` product, except for `CrowdinXCTestScreenshots`, which is a separate `CrowdinXCTestScreenshots` product.

:::note CocoaPods
With the deprecated CocoaPods installation, these parts are available as subspecs, so you can pick the ones you need by adding `pod 'CrowdinSDK/Subspec_Name'` to your `Podfile`. See [Installation](/installation#migrating-from-cocoapods) for how to migrate to Swift Package Manager.
:::

CrowdinSDK contains several submodules:

### Core

This submodule contains core SDK functionality, such as switching localized strings and algorithms for current language detection.

This is a default submodule, so it is always included in the `CrowdinSDK` package (and in the *CrowdinSDK* pod for CocoaPods).

### CrowdinFileSystem

Utility submodule for working with files on the device file system. It is used by other submodules to store and read downloaded localization files.

### CrowdinProvider

Submodule for downloading localizations from the Crowdin server.

This is a default submodule, so it is always included in the `CrowdinSDK` package (and in the *CrowdinSDK* pod for CocoaPods).

### CrowdinAPI

Crowdin API implementation to work with the Crowdin server.

### Screenshots

It contains all functionality related to the Screenshots feature. With CocoaPods, add the `CrowdinSDK/Screenshots` pod to your `Podfile` to enable it.

### RealtimeUpdate

It contains all functionality related to the Real-Time Preview feature. With CocoaPods, add the `CrowdinSDK/RealtimeUpdate` pod to your `Podfile` to enable it.

### RefreshLocalization

It contains functionality to force refresh localization strings. With CocoaPods, add the `CrowdinSDK/RefreshLocalization` pod to your `Podfile` to enable it.

### LoginFeature

It contains login functionality. With CocoaPods, add the `CrowdinSDK/LoginFeature` pod to your `Podfile` to enable it.

To set up this feature, create a `CrowdinLoginConfig` object and pass it to `CrowdinSDKConfig`.

### IntervalUpdate

It contains functionality for updating localization strings at a defined time interval. With CocoaPods, add the `CrowdinSDK/IntervalUpdate` pod to your `Podfile` to enable it.

### Settings

Submodule for testing all features. It contains a simple view with the possibility to enable/disable the following features: Force localization refresh, Interval localization updates, Real-Time Preview, and Screenshots. With CocoaPods, add the `CrowdinSDK/Settings` pod to your `Podfile` to enable it.

To display the settings view, call the `CrowdinSDK.showSettings()` method in Swift or `[CrowdinSDK showSettings]` in Objective-C. Note that you need to set up all features with the `CrowdinSDKConfig` object.

The settings view has two states: closed and open. See the [SDK Controls](/advanced-features/sdk-controls) page for more details.

### CrowdinXCTestScreenshots

It contains functionality for capturing and uploading screenshots to Crowdin from XCUITest UI tests. Add the `CrowdinXCTestScreenshots` product to the UI tests target (or, with CocoaPods, the `CrowdinSDK/CrowdinXCTestScreenshots` pod in your `Podfile`). See the [Screenshots Automation](/guides/screenshots-automation) guide for more details.
