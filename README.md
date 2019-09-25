[<p align="center"><img src="https://support.crowdin.com/assets/logos/crowdin-dark-symbol.png" data-canonical-src="https://support.crowdin.com/assets/logos/crowdin-dark-symbol.png" width="200" height="200" align="center"/></p>](https://crowdin.com)

# Crowdin IOS SDK

Crowdin IOS SDK delivers all new translations from Crowdin project to the application immediately. So there is no need to update this application via App Store to get the new version with the localization.


## Table of Contents
* [Requirements](#requirements)
* [Dependencies](#dependencies)
* [Installation](#installation)
* [Quick Start](#quick-start)
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

#### Cocoapods

To install CrowdinSDK via [cocoapods](https://cocoapods.org), please make shure you have cocoapods installed locally. If not, please install it with following command: ```sudo gem install cocoapods```. 

Detailed instruction can be found [here](https://guides.cocoapods.org/using/getting-started.html).

 To install it, simply add the following line to your Podfile:

```ruby
pod 'CrowdinSDK'
```

To install from cocoapods spec repository (will be avalaible after publishing to cocoapods.):

```
target 'MyApp' do
  pod 'CrowdinSDK'
end
```

To install from gitlab repository (This option will be removed from this document in the future.):

```
target 'MyApp' do
  pod 'CrowdinSDK', :git => 'https://github.com/crowdin/mobile-sdk-ios.git'
end
```


To install from local sources (This option will be removed from this document in the future.):

```
target 'MyApp' do
  pod 'CrowdinSDK', :path => '../../CrowdinSDK' - where '../../CrowdinSDK' is path to local sources.
end
```

After you've added CrowdinSDK to your Podfile, please run ```pod install``` in your project directory, open `App.xcworkspace` and build it. 

## Quick Start

In order to start using CrowdinSDK you need to import and initialize it in your AppDelegate. 

By default, CrowdinSDK uses Crowdin localization provider. In order to properly setup it please read [providers documentation](Documentation/Providers.md). 

Also you can use your own provider implementation. To get the detailed istructions please read [providers documentation](Documentation/Providers.md) or look at 'CustomLocalizationProvider in Example project'.

### Swift

In AppDelegate.swift add ```import CrowdinSDK```.

In ```func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool``` method add: 

```CrowdinSDK.start()```

### Objective-C

In AppDelegate.m add ```@import CrowdinSDK``` or ```#import<CrowdinSDK/CrowdinSDK.h>```.

In ```- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions``` method add: 

```[CrowdinSDK start];```

If you have pure Objective-C project, then you will need to do some additional steps:

- ```$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)``` to your Library Search Paths.
- Add ```use_frameworks!``` to your Podfile.

### Example Project

To run the example project, first clone the repo and run `pod install` from the Example directory. All functionality described in this [article](Documentation/TestApplication.md).

## Contribution
We are happy to accept contributions to the Crowdin iOS SDK. To contribute please do the following:
1. Fork the repository on GitHub.
2. Decide which code you want to submit. A submission should be a set of changes that addresses one issue in the issue tracker. Please file one change per issue, and address one issue per change. If you want to make a change that doesn't have a corresponding issue in the issue tracker, please file a new ticket!
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

The Crowdin iOS SDK for is licensed under the MIT License. 
See the LICENSE.md file distributed with this work for additional 
information regarding copyright ownership.
</pre>
