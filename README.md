# CrowdinSDK

[![CI Status](https://img.shields.io/travis/Serhii-Londar/CrowdinSDK.svg?style=flat)](https://travis-ci.org/Serhii Londar/CrowdinSDK)
[![Version](https://img.shields.io/cocoapods/v/CrowdinSDK.svg?style=flat)](https://cocoapods.org/pods/CrowdinSDK)
[![License](https://img.shields.io/cocoapods/l/CrowdinSDK.svg?style=flat)](https://cocoapods.org/pods/CrowdinSDK)
[![Platform](https://img.shields.io/cocoapods/p/CrowdinSDK.svg?style=flat)](https://cocoapods.org/pods/CrowdinSDK)

## Example Project

To run the example project, clone the repo, and run `pod install` from the Example directory first. All functionality desctibed in [here](Documentation/TestApplication.md)


## Requirenments

- Xcode 10.2 
- Swift 4.2 
- iOS 9.0

## Installation

#### Cocoapods

To install CrowdinSDK via [cocoapods](https://cocoapods.org), please make shure you have installed cocoapods locally. If not, please install it with following command: ```sudo gem install cocoapods```. Detailed instruction can be found [here](https://guides.cocoapods.org/using/getting-started.html).

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

To install from gitlab repository (This option will be removed from this document in future.):

```
target 'MyApp' do
  pod 'CrowdinSDK', :git => 'git@gitlab.com:crowdin-ext/mobile-sdk-ios.git'
end
```


To install from local sources (This option will be removed from this document in future.):

```
target 'MyApp' do
  pod 'CrowdinSDK', :path => '../../CrowdinSDK' - where '../../CrowdinSDK' is path to local sources.
end
```

After you've add CrowdinSDK to your Podfile, please run ```pod install``` in your project directory, open App.xcworkspace and build. 

### Carthage [TBA]

### Manual [TBA]


## Setup SDK

To start use CrowdinSDK you will need to import and initialize it your AppDelegate. By default CrowdinSDK uses Crowdin localization provider. To properly setup please read [providers documentation](/Documetation/Providers.md). 

Also you can use your own provider implementation to get detailed istructions please read [providers documentation](/Documetation/Providers.md) or look on 'CustomLocalizationProvider in Example project'.

##### Swift

In AppDelegate.swift add ```import CrowdinSDK```.

In ```func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool``` method add: 

```CrowdinSDK.start()```

##### Objective-C

In AppDelegate.m add ```@import CrowdinSDK``` or ```#import<CrowdinSDK/CrowdinSDK.h>```.

In ```- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions``` method add: 

```[CrowdinSDK start];```

If you have pure Objective-C project than you will need to do some additional steps:

- ```$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)``` to your Library Search Paths.
- Add ```use_frameworks!``` to your Podfile.

## Author

Serhii Londar, serhii.londar@gmail.com

## License

CrowdinSDK is available under the MIT license. See the LICENSE file for more info.
