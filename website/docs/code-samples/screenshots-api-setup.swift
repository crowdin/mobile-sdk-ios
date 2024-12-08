let crowdinProviderConfig = CrowdinProviderConfig(hashString: "{your_distribution_hash}",
    sourceLanguage: "{source_language}",
    organizationName: "{organization_name}") // Optional. Required for Enterprise only

let crowdinSDKConfig = CrowdinSDKConfig.config()
    .with(crowdinProviderConfig: crowdinProviderConfig)
    .with(screenshotsEnabled: true)
    // highlight-next-line
    .with(accessToken: "your_access_token")
    .with(settingsEnabled: true)

CrowdinSDK.startWithConfig(crowdinSDKConfig, completion: {
    // SDK is ready to use, put code to change language, etc. here
})
