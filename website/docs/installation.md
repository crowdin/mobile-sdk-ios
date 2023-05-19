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

Once you have your Swift package set up, adding CrowdinSDK as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```swift
dependencies: [
    .package(url: "https://github.com/crowdin/mobile-sdk-ios.git", from:"1.4.0")
]
```

## Requirements

* Xcode 10.2
* Swift 4.2
* iOS 9.0

:::tip
R-Swift applications are also supported by the Crowdin iOS SDK.
:::

## Dependencies

* [Starscream](https://github.com/daltoniam/Starscream) - Websockets in swift for iOS and OSX.

## See also

- [Setup](setup.mdx)
