# Providers

## CrowdinLocalizationProvider

Default localization provider for CrowdinSDK. This class works with Crowdin content delivery API, downloads localization files and substitude device localization with downloaded.

There are two ways to setup CrowdinLocalizationProvider. 

### Info.plist

To setup CrowdinProvider you should add following keys to Info.plist file:

- **CrowdinHash** - hash value of Content Delivery release.
- **CrowdinProjectIdentifier** - crowdin project identifier.
- **CrowdinPluralsFileNames** - array of plurals file names on crowdin server.
- **CrowdinStringsFileNames** - array of strings file names on crowdin server.
- **CrowdinProjectKey** - project API key.

Example:

<img src='./Providers/Infoplist.png' width="600"/>

In this case after you setup your SDK with CrowdinSDK start method, SDK will read all this values from Info.plist file and download all needed localization files from provided crowdin project.


### AppDelegate:

#### Swift:

In AppDelegate.swift file add:

```swift
import CrowdinSDK
```

In ```func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool``` method add: 

```swift
CrowdinSDK.start(with: "66f02b964afeb77aea8d191e68748abc", stringsFileNames: ["Localizable.strings", "Base.strings"], pluralsFileNames: ["Localizable.stringsdict", "Base.stringsdict"], projectIdentifier: "content-er4", projectKey: "af3d3deb8d45b7f7ac4e58c83ca2bc0c")
```

#### Objective-C:
In AppDelegate.m file add:

```@import CrowdinSDK``` or ```#import<CrowdinSDK/CrowdinSDK.h>```.


In ```- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions``` method add: 

```objective-c
[CrowdinSDK startWith:@"66f02b964afeb77aea8d191e68748abc"
         stringsFileNames:@[@"Localizable.strings", @"Base.strings"]
         pluralsFileNames:@[@"Localizable.stringsdict", @"Base.stringsdict"]
        projectIdentifier:@"content-er4"
               projectKey:@"af3d3deb8d45b7f7ac4e58c83ca2bc0c"];
```

After application will start it SDK will detect current device localization and download strings and plurals from crowdin server for this localization. 

## LocalLocalizationProvider

Provider implementation will extract localization strings from application bundle and add append it with following format: "'local string' [cw]". 

This provider recomended using only for testing purposes. 

To use this localization provider you should setup CrowdinSDK with custom provider:

#### Swift:

In AppDelegate.swift file add:

```swift
import CrowdinSDK
```

In ```func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool``` method add: 

```swift
CrowdinSDK.start(LocalLocalizationProvider())
```

#### Objective-C:
In AppDelegate.m file add:

```@import CrowdinSDK``` or ```#import<CrowdinSDK/CrowdinSDK.h>```.


In ```- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions``` method add: 

```objective-c
[CrowdinSDK startWith:[LocalLocalizationProvider new]];
```

After application will start it SDK will detect current device localization and extract all strings and plurals for this localization add append it with ' [cw]' string. 

## Firebase [TBA]



## Custom Localization Provider [TBA]