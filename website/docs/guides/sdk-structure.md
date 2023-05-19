# SDK Structure

## Subspecs

CrowdinSDK divided into separate parts called subspecs. To install some of these parts via cocoapods you'll need to add `pod 'CrowdinSDK/Subspec_Name'` in your pod file.

CrowdinSDK contains several submodules:

### Core
This submodule contains core SDK functionality, such as functionality for switching localized strings, algorithms for current language detection.

This is the default submodule, which means if you set up SDK via cocapods with pod *CrowdinSDK* this submodule will be included.

### CrowdinProvider
Submodule for downloading localizations from the Crowdin server.

This is the default submodule, which means if you set up SDK via cocapods with pod *CrowdinSDK* this submodule will be included by default.

### CrowdinAPI
Crowdin API implementation to work with the Crowdin server.

### MappingManager
All classes related to strings mapping downloading and parsing. This subspec is used only as a dependency for realtime updates and screenshots subspecs.

### Screenshots
It contains all functionality related to Screenshots feature. To enable this feature please add pod `CrowdinSDK/Screenshots` to your pod file.

### RealtimeUpdate
It contains all functionality related to the Real-Time Preview feature. To enable this feature please add pod `CrowdinSDK/RealtimeUpdate` to your pod file.

### RefreshLocalization
It contains functionality to force refresh localization strings. To enable this feature please add pod `CrowdinSDK/RefreshLocalization` to your pod file.

### Login
It contains login functionality. To enable this feature please add pod `CrowdinSDK/Login` to your pod file.

To set up this feature you need to setup create `CrowdinLoginConfig` object and pass it to `CrowdinSDKConfig`.

### IntervalUpdate
It contains functionality for update localization strings every defined time interval. To enable this feature please add pod `CrowdinSDK/IntervalUpdate` to your pod file.

### Settings
Submodule for testing all features. It contains a simple view with the possibility to enable/disable the following features: Force localization refresh, Interval localization updates, Real-time Preview, Screenshots. To enable this feature please add pod `CrowdinSDK/Settings` to your pod file.

To display settings view you can call `CrowdinSDK.showSettings()` method for Swift and `[CrowdinSDK showSettings]` for Objective-C. Note that you need to set up all features with `CrowdinSDKConfig` object.

Settings view has two states: Closed and open.
