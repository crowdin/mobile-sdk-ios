## Requirements: 
- Xcode 10.2
- Swift 4.2

## Integration

### Cocoapods [TBA]

### Carthage [TBA]

### Manual

This tutorial used on this open source project: [eoshub-ios](https://github.com/eoshubio/eoshub-ios) - Easy access to the EOS network. [https://eos-hub.io](https://eos-hub.io).

#### 1. Install all dependencies via 'pod install' command:

<img src='./Screenshots/pod install.png' width="600"/>


#### 2. Check out CrowdinSDK.framework from repository home path:
<img src='./Screenshots/main folder.png' width="600"/>

#### 3. Drag end dorop CrowdinSDK.framework to your xcode project:

<img src='./Screenshots/drag and drop.png' width="600"/>

#### 4. Add CrowdinSDK.framework to Embeded Binaries:

Press Project -> Target -> General, And under Embeded Binaries section press "Add Items" (Plus button):

<img src='./Screenshots/add framework1.png' width="600"/>

Select Crowdin.framework from list:

<img src='./Screenshots/add framework2.png' width="600"/>

Make sure that crowdin sdk added to "Embeded Binaries" and to "Lonked Frameworks and Libraries" sections only once:

<img src='./Screenshots/add framework3.png' width="600"/>

#### 5. Setup SDK.

##### Swift

In AppDelegate.swift add ```import CrowdinSDK```.

In ```func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool``` method add: 

```CrowdinSDK.start()```

<img src='./Screenshots/app delegate.png' width="600"/>

##### Objective-C
In AppDelegate.m add ```@import CrowdinSDK``` or ```#import<CrowdinSDK/CrowdinSDK.h>```.

In ```- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions``` method add: 

```[CrowdinSDK start];```

#### 6. Run application.
When you run your application, all localized strings shoul be appended with following construction:  
```[current localization][cw]```, f.e. [en][cw].

<img src='./Screenshots/simulator1.png' width="100"/>
<img src='./Screenshots/simulator2.png' width="100"/>
<img src='./Screenshots/simulator3.png' width="100"/>
<img src='./Screenshots/simulator4.png' width="100"/>
<img src='./Screenshots/simulator5.png' width="100"/>
