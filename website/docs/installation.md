# Installation

## Cocoapods

1. Cocoapods

   To install Crowdin iOS SDK via [cocoapods](https://cocoapods.org), make sure you have cocoapods installed locally. If not, install it with following command: `sudo gem install cocoapods`. Detailed instruction can be found [here](https://guides.cocoapods.org/using/getting-started.html).

   Add the following line to your Podfile:

   ```swift title="Podfile"
   pod 'CrowdinSDK'
   ```

2. Cocoapods spec repository:

   ```swift
   target 'MyApp' do
     pod 'CrowdinSDK'
   end
   ```

   :::tip
   You can also specify the exact branch of the Crowdin iOS SDK in your Podfile:

   ```swift
   pod 'CrowdinSDK', :git => 'https://github.com/crowdin/mobile-sdk-ios.git', :branch => 'dev'
   ```
   :::

3. Working with App Extensions:

   Upon `pod install` result, you might experience some building issues in case your application embeds target extensions.

   Example error:

   > 'shared' (Swift) / 'sharedApplication' (Objective-C) is unavailable: not available on iOS (App Extension) - Use view controller based solutions where appropriate instead.

   In this scenario you'll need to add a `post_install` script to your Podfile

    ```swift
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

After you've added *CrowdinSDK* to your Podfile, run `pod install` in your project directory, open `App.xcworkspace` and build it.

## Swift Package Manager

The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the Swift compiler.

To add CrowdinSDK to your project using SPM:

1. In Xcode, select File > Add Packages...
2. Enter the package repository URL: `https://github.com/crowdin/mobile-sdk-ios.git`
3. Select the version you want to use (latest release recommended)
4. Click Add Package

Alternatively, you can add it directly to your Package.swift:

```swift title="Package.swift"
dependencies: [
    .package(url: "https://github.com/crowdin/mobile-sdk-ios.git", from: "1.9.0")
]
```

:::tip
For better version control, you can specify an exact version or version range:

```swift
.package(url: "https://github.com/crowdin/mobile-sdk-ios.git", .upToNextMajor(from: "1.9.0"))
```
:::

## Requirements

* Xcode 15.0+
* Swift 5.0+
* iOS 12.0+

:::tip
R-Swift applications are also supported by the Crowdin iOS SDK.
:::

## Dependencies

* [Starscream](https://github.com/daltoniam/Starscream) (~> 4.0.4) - Websockets in swift for iOS and OSX
* [BaseAPI](https://github.com/serhii-londar/BaseAPI.git) (~> 0.2.2)

## See also

- [Setup](setup.mdx)
- [Screenshots](advanced-features/screenshots.mdx)
- [Real time preview](advanced-features/real-time-preview.mdx)
