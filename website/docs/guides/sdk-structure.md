---
description: Explore the Crowdin iOS SDK structure - Core, CrowdinProvider, Screenshots, RealtimeUpdate, LoginFeature, and other subspecs.
---

# SDK Structure

## Subspecs

CrowdinSDK is divided into separate parts called subspecs. To install some of these parts via CocoaPods, add `pod 'CrowdinSDK/Subspec_Name'` to your `Podfile`.

CrowdinSDK contains several submodules:

### Core

This submodule contains core SDK functionality, such as switching localized strings and algorithms for current language detection.

This is a default submodule, which means that if you set up the SDK via CocoaPods with the *CrowdinSDK* pod, this submodule will be included.

### CrowdinFileSystem

Utility submodule for working with files on the device file system. It is used by other submodules to store and read downloaded localization files.

### CrowdinProvider

Submodule for downloading localizations from the Crowdin server.

This is a default submodule, which means that if you set up the SDK via CocoaPods with the *CrowdinSDK* pod, this submodule will be included by default.

### CrowdinAPI

Crowdin API implementation to work with the Crowdin server.

### Screenshots

It contains all functionality related to the Screenshots feature. To enable this feature, add the `CrowdinSDK/Screenshots` pod to your `Podfile`.

### RealtimeUpdate

It contains all functionality related to the Real-Time Preview feature. To enable this feature, add the `CrowdinSDK/RealtimeUpdate` pod to your `Podfile`.

### RefreshLocalization

It contains functionality to force refresh localization strings. To enable this feature, add the `CrowdinSDK/RefreshLocalization` pod to your `Podfile`.

### LoginFeature

It contains login functionality. To enable this feature, add the `CrowdinSDK/LoginFeature` pod to your `Podfile`.

To set up this feature, create a `CrowdinLoginConfig` object and pass it to `CrowdinSDKConfig`.

### IntervalUpdate

It contains functionality for updating localization strings at a defined time interval. To enable this feature, add the `CrowdinSDK/IntervalUpdate` pod to your `Podfile`.

### Settings

Submodule for testing all features. It contains a simple view with the possibility to enable/disable the following features: Force localization refresh, Interval localization updates, Real-Time Preview, and Screenshots. To enable this feature, add the `CrowdinSDK/Settings` pod to your `Podfile`.

To display the settings view, call the `CrowdinSDK.showSettings()` method in Swift or `[CrowdinSDK showSettings]` in Objective-C. Note that you need to set up all features with the `CrowdinSDKConfig` object.

The settings view has two states: closed and open. See the [SDK Controls](/advanced-features/sdk-controls) page for more details.

### CrowdinXCTestScreenshots

It contains functionality for capturing and uploading screenshots to Crowdin from XCUITest UI tests. To enable this feature, add the `CrowdinSDK/CrowdinXCTestScreenshots` pod to the UI tests target in your `Podfile`. See the [Screenshots Automation](/guides/screenshots-automation) guide for more details.
