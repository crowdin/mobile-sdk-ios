# Debug and Logging

Crowdin iOS SDK provides detailed debug mode - "Logs" tab in the [SDK Controls](/advanced-features/sdk-controls) module and logging into XCode console.

To enable console logging, add the following option to your `CrowdinSDKConfig`:

```swift
.with(debugEnabled: true)
```

Crowdin SDK collects log messages for all actions performed by the SDK (login/logout, language downloads, API calls). There is a possibility to set up a callback for these logs. This callback will return log text every time a new log is created. To subscribe to receive log messages, just add a new callback like this:

```swift
CrowdinSDK.setOnLogCallback { logMessage in
   print("LOG MESSAGE - \(logMessage)")
}
```
