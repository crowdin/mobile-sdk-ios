# Example project

Crowdin [iOS SDK Example project](https://github.com/crowdin/mobile-sdk-ios/tree/master/Example) is a simple todo app that illustrates how you can use Crowdin SDK features with a real iOS app. This app's primary purpose is to show the Crowdin SDK integration process in action and test the possibilities it provides.

## App Overview

In the Crowdin iOS SDK Example app, you can create reminders, add them to groups, create location-based reminders, and so on. This Example app is based on [AppleReminders](https://github.com/atticus183/AppleReminders) project.

## Configuration

You can find all the needed configuration code in [*SceneDelegate.swift*](https://github.com/crowdin/mobile-sdk-ios/blob/master/Example/AppleReminders/SceneDelegate.swift) file. Fill in the following fields using your credentials and run the app.

```swift
private let distributionHash = "your_distribution_hash" // Crowdin OTA Content Delivery distribution hash
private let sourceLanguage = "source_language" // Crowdin project source language (e.g. "en")
    
// Authentication - use either OAuth credentials or access token
// OAuth authentication:
private let clientId = "your_client_id" // Crowdin OAuth Client ID (needed for Screenshots and Real-Time Preview features)
private let clientSecret = "your_client_secret" // Crowdin OAuth Client Secret (needed for Screenshots and Real-Time Preview features)

// OR access token authentication (alternative to OAuth):
private let accessToken = "your_access_token" // Crowdin access token (can be used instead of OAuth for Screenshots and Real-Time Preview features)
```

To run the example project, clone the repo, and run `pod install` from the Example directory, then open `AppleReminders.xcworkspace`.

To read more about Crowdin iOS SDK configuration read [Setup](/setup).
