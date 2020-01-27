## Requirements: 

- Xcode 10.2
- Swift 4.2
- iOS 9.0

This tutorial used in this open source project: [eoshub-ios](https://github.com/eoshubio/eoshub-ios) - Easy access to the EOS network. [https://eos-hub.io](https://eos-hub.io).

#### 1. Install all dependencies via 'pod install' command:

<img src='./FrameworkTutorial/pod install.png' width="600"/>


#### 2. Check out CrowdinSDK.framework from repository home path:
<img src='./FrameworkTutorial/main folder.png' width="600"/>

#### 3. Drag end drop CrowdinSDK.framework to your xcode project:

<img src='./FrameworkTutorial/drag and drop.png' width="600"/>

#### 4. Add CrowdinSDK.framework to Embeded Binaries:

Press Project -> Target -> General, and under Embeded Binaries section press "Add Items" (Plus button):

<img src='./FrameworkTutorial/add framework1.png' width="600"/>

Select CrowdinSDK.framework from list:

<img src='./FrameworkTutorial/add framework2.png' width="600"/>

Make sure that crowdin sdk is added to "Embeded Binaries" and to "Linked Frameworks and Libraries" sections only once:

<img src='./FrameworkTutorial/add framework3.png' width="600"/>

#### 5. Setup SDK.

##### Swift

In AppDelegate.swift add ```import CrowdinSDK```.

In ```func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool``` method add: 

```CrowdinSDK.start()```

<img src='./FrameworkTutorial/app delegate.png' width="600"/>

##### Objective-C
In AppDelegate.m add ```@import CrowdinSDK``` or ```#import<CrowdinSDK/CrowdinSDK.h>```.

In ```- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions``` method add: 

```[CrowdinSDK start];```

#### 6. Run application.
When you will run your application, all localized strings should be appended with following construction:  
```[current localization][cw]```, f.e. [en][cw].

<img src='./FrameworkTutorial/simulator1.png' width="100"/>
<img src='./FrameworkTutorial/simulator2.png' width="100"/>
<img src='./FrameworkTutorial/simulator3.png' width="100"/>
<img src='./FrameworkTutorial/simulator4.png' width="100"/>
<img src='./FrameworkTutorial/simulator5.png' width="100"/>
