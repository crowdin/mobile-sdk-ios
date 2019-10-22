[<p align="center"><img src="https://support.crowdin.com/assets/logos/crowdin-dark-symbol.png" data-canonical-src="https://support.crowdin.com/assets/logos/crowdin-dark-symbol.png" width="200" height="200" align="center"/></p>](https://crowdin.com)

# Crowdin iOS SDK

Crowdin iOS SDK delivers all new translations from Crowdin project to the application immediately. So there is no need to update this application via App Store to get the new version with the localization.

The SDK provides:

* Over-The-Air Content Delivery – the localized files can be sent to the application from the project whenever needed
* Real-time Preview – all the translations that are done via Editor can be shown in the application in real-time
* Screenshots – all screenshots made in the application may be automatically sent to your Crowdin project with tagged source strings

For more about Crowdin iOS SDK see the [documentation](https://support.crowdin.com/enterprise/sdk-ios/).

## Status

[![GitHub issues](https://img.shields.io/github/issues/crowdin/mobile-sdk-ios)](https://github.com/crowdin/mobile-sdk-ios/issues)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/m/crowdin/mobile-sdk-ios)](https://github.com/crowdin/mobile-sdk-ios/graphs/commit-activity)
[![GitHub last commit](https://img.shields.io/github/last-commit/crowdin/mobile-sdk-ios)](https://github.com/crowdin/mobile-sdk-ios/commits/master)
[![GitHub contributors](https://img.shields.io/github/contributors/crowdin/mobile-sdk-ios)](https://github.com/crowdin/mobile-sdk-ios/graphs/contributors)
[![GitHub License](https://img.shields.io/github/license/crowdin/mobile-sdk-ios)](https://github.com/crowdin/mobile-sdk-ios/blob/master/LICENSE)


[![Azure DevOps builds (branch)](https://img.shields.io/azure-devops/build/crowdin/mobile-sdk-ios/14/master?logo=azure-pipelines)](https://dev.azure.com/crowdin/mobile-sdk-ios/_build/latest?definitionId=14&branchName=master)
[![codecov](https://codecov.io/gh/crowdin/mobile-sdk-ios/branch/master/graph/badge.svg)](https://codecov.io/gh/crowdin/mobile-sdk-ios)
[![Azure DevOps tests (branch)](https://img.shields.io/azure-devops/tests/crowdin/mobile-sdk-ios/14/master)](https://dev.azure.com/crowdin/mobile-sdk-ios/_build/latest?definitionId=14&branchName=master)



## Table of Contents
* [Requirements](#requirements)
* [Dependencies](#dependencies)
* [Installation](#installation)
* [Setup](#setup)
* [Advanced Features](#advanced-features)
  * [Real-time Preview](#real-time-preview)
  * [Screenshots](#screenshots)
  * [Force Update](#force-update)
* [Contribution](#contribution)
* [Seeking Assistance](#seeking-assistance)
* [Author](#author)
* [License](#license)

## Requirements

* Xcode 10.2 
* Swift 4.2 
* iOS 9.0

## Dependencies

* [Starscream](https://github.com/daltoniam/Starscream) - Websockets in swift for iOS and OSX.

## Installation

1. Cocoapods

   To install CrowdinSDK via [cocoapods](https://cocoapods.org), please make shure you have cocoapods installed locally. If not, please install it with following command: ```sudo gem install cocoapods```. 

   Detailed instruction can be found [here](https://guides.cocoapods.org/using/getting-started.html).

    To install it, simply add the following line to your Podfile:

   ```swift
   pod 'CrowdinSDK'
   ```

2. Cocoapods spec repository [TBA] (will be avalaible after publishing to cocoapods):

   ```swift
   target 'MyApp' do
     pod 'CrowdinSDK'
   end
   ```

3. GitHub repository (This option will be removed from this document in the future):

   ```swift
   target 'MyApp' do
     pod 'CrowdinSDK', :git => 'https://github.com/crowdin/mobile-sdk-ios.git'
   end
   ```

4. Local sources (This option will be removed from this document in the future):

   ```swift
   target 'MyApp' do
     pod 'CrowdinSDK', :path => '../../CrowdinSDK'
   end
   ```
   
   `'../../CrowdinSDK'` - path to local sources.

After you've added CrowdinSDK to your Podfile, please run ```pod install``` in your project directory, open `App.xcworkspace` and build it. 

## Setup

In order to start using CrowdinSDK you need to import and initialize it in your AppDelegate. 

By default, CrowdinSDK uses Crowdin localization provider. In order to properly setup it please read [providers documentation](Documentation/Providers.md). 

Also you can use your own provider implementation. To get the detailed istructions please read [providers documentation](Documentation/Providers.md) or look at *CustomLocalizationProvider* in *Example project*.


1. Enable *Over-The-Air Content Delivery* in your Crowdin project so that application can pull translations from CDN vault. 

2. Open *AppDelegate.swift* file and add:

   ```swift
   import CrowdinSDK
   ```

3. In ```func application(...) -> Bool``` method add:

   ```swift
   let crowdinProviderConfig = CrowdinProviderConfig(hashString: "{your_distribution_hash}",
      stringsFileNames: ["{path_to_file_with_export_pattern}"], // only language codes are supported
      pluralsFileNames: ["{path_to_file_with_plurals}"],
      localizations: [target_languages],
      sourceLanguage: source_language)

   CrowdinSDK.startWithConfig(crowdinSDKConfig) // required
   ```

   `your_distribution_hash` - when distribution added you will get your unique hash.

   `path_to_file_with_export_pattern` - files from Crowdin project, translations from which will be sent to the application. Example: `"core.strings", "arrays.strings"`

   `path_to_file_with_plurals` - **plural** files from Crowdin project, translations from which will be sent to the application. Example: `"core.stringsdict"`

   `target_languages` - target languages are the ones you’re translating to. Example: `"fr","uk","de"`

   `source_language` - source language in your Crowdin project. Example - "en". Required for real time/screenshot functionalities.


<details>
<summary>Objective-C</summary>

In *AppDelegate.m* add:

```objective-c
@import CrowdinSDK
``` 

or 

```objective-c
#import<CrowdinSDK/CrowdinSDK.h>
```

In ```application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions``` method add: 

```objective-c
[CrowdinSDK start];
```

If you have pure Objective-C project, then you will need to do some additional steps:

Add the following code to your Library Search Paths:
```objective-c
$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)
```

Add ```use_frameworks!``` to your Podfile.

</details>


### Example Project

To run the example project, first clone the repo and run `pod install` from the Example directory. All functionality described in this [article](Documentation/TestApplication.md).

## Advanced Features

### Real-time Preview

This feature allows translators to see translations in the application in real-time. It can also be used by managers and QA team to preview translations before release.

Add the below code to your *Podfile*:

```swift
use_frameworks!
target 'your-app' do
pod 'CrowdinSDK', :git => 'git@github.com:crowdin/mobile-sdk-ios.git'
pod 'CrowdinSDK/RealtimeUpdate', 'git@github.com:crowdin/mobile-sdk-ios.git'
end
```

Open *AppDelegate.swift* file and in ```func application(...) -> Bool``` method add:

```swift
let crowdinProviderConfig = CrowdinProviderConfig(hashString: "{your_distribution_hash}",
    stringsFileNames: ["{path_to_file_with_export_pattern}"],
    pluralsFileNames: ["{path_to_file_with_plurals}"],
    localizations: [{target_languages}],
    sourceLanguage: "{source_language}")

let loginConfig = CrowdinLoginConfig(clientId: "client_id", // required for real-time preview
    clientSecret: "client_secret",
    scope: "project.screenshot",
    redirectURI: "crowdintest",
    organizationName: "{organization_name}")

let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
    .with(loginConfig: loginConfig) // required for screenshots and real-time preview            
    .with(settingsEnabled: true) // optional: to add ‘settings’ button
    .with(reatimeUpdatesEnabled: true) // button for real-time preview 

CrowdinSDK.startWithConfig(crowdinSDKConfig) // required
```

### Screenshots

Enable if you want all the screenshots made in the application to be automatically sent to your Crowdin project with tagged strings. This will provide additional context for translators.

Add the below code to your *Podfile*:

```swift
use_frameworks!
target 'your-app' do
pod 'CrowdinSDK', :git => 'git@github.com:crowdin/mobile-sdk-ios.git'
pod 'CrowdinSDK/Screenshots', 'git@github.com:crowdin/mobile-sdk-ios.git' // required for screenshots
pod 'CrowdinSDK/Settings', 'git@github.com:crowdin/mobile-sdk-ios.git' // optional: to add ‘settings’ button
end
```

Open *AppDelegate.swift* file and in ```func application(...) -> Bool``` method add:

```swift
let crowdinProviderConfig = CrowdinProviderConfig(hashString: "{your_distribution_hash}",
    stringsFileNames: ["{path_to_file_with_export_pattern}"],
    pluralsFileNames: ["{path_to_file_with_plurals}"],
    localizations: [{target_languages}],
    sourceLanguage: "{source_language}")

let loginConfig = CrowdinLoginConfig(clientId: "client_id", // required for screenshots
    clientSecret: "client_secret",
    scope: "project.screenshot",
    redirectURI: "crowdintest",
    organizationName: "{organization_name}")

let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
    .with(screenshotsEnabled: true) // button for screenshots
    .with(loginConfig: loginConfig) // required for screenshots and real-time preview            
    .with(settingsEnabled: true) // optional: to add ‘settings’ button 

CrowdinSDK.startWithConfig(crowdinSDKConfig) // required
```

### Force Update

Enable to have the option of initiating translation updates while using the application.

Add the below code to your *Podfile*:

```swift
use_frameworks!
target 'your-app' do
pod 'CrowdinSDK', :git => 'git@github.com:crowdin/mobile-sdk-ios.git'
pod 'CrowdinSDK/RefereshLocalization', 'git@github.com:crowdin/mobile-sdk-ios.git'
end
```

Open *AppDelegate.swift* file and in ```func application(...) -> Bool``` method add:

```swift
let crowdinProviderConfig = CrowdinProviderConfig(hashString: "{your_distribution_hash}",
   stringsFileNames: ["{path_to_file_with_export_pattern}"],
   pluralsFileNames: ["{path_to_file_with_plurals}"],
   localizations: [{target_languages}],
   sourceLanguage: "{source_language}")
CrowdinSDK.startWithConfig(crowdinProviderConfig)
```

Note: only language codes are supported in export pattern for `path_to_file_with_export_pattern`

## Contribution
We are happy to accept contributions to the Crowdin iOS SDK. To contribute please do the following:
1. Fork the repository on GitHub.
2. Decide which code you want to submit. Commit your changes and push to the new branch.
3. Ensure that your code adheres to standard conventions, as used in the rest of the library.
4. Ensure that there are unit tests for your code.
5. Submit a pull request with your patch on Github.

## Seeking Assistance
If you find any problems or would like to suggest a feature, please feel free to file an issue on Github at [Issues Page](https://github.com/crowdin/mobile-sdk-ios/issues).

If you've found an error in these samples, please [contact](https://crowdin.com/contacts) our Support Team.

## Author

Serhii Londar, serhii.londar@gmail.com

## License
<pre>
Copyright © 2019 Crowdin

The Crowdin iOS SDK is licensed under the MIT License. 
See the LICENSE file distributed with this work for additional 
information regarding copyright ownership.

Except as contained in the LICENSE file, the name(s) of the above copyright 
holders shall not be used in advertising or otherwise to promote the sale, 
use or other dealings in this Software without prior written authorization.
</pre>
