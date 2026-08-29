---
description: Enable the Crowdin iOS SDK debug mode and console logging, and subscribe to SDK log messages with a callback.
---

# Debug and Logging

Crowdin iOS SDK provides a detailed debug mode: the *Logs* tab in the [SDK Controls](/advanced-features/sdk-controls) widget and logging to the Xcode console.

To enable console logging, add the following option to your `CrowdinSDKConfig`:

```swift
.with(debugEnabled: true)
```

Crowdin SDK collects log messages for all actions performed by the SDK (login/logout, language downloads, API calls). You can also set up a callback for these logs. This callback will return the log text every time a new log is created. To subscribe to log messages, add a callback like this:

```swift
CrowdinSDK.setOnLogCallback { logMessage in
   print("LOG MESSAGE - \(logMessage)")
}
```
