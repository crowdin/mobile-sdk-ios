let crowdinProviderConfig = CrowdinProviderConfig(hashString: "{your_distribution_hash}",
    sourceLanguage: "{source_language}",
    organizationName: "{organization_name}") // Optional. Required for Enterprise only

let crowdinSDKConfig = CrowdinSDKConfig.config()
    .with(crowdinProviderConfig: crowdinProviderConfig)
    .with(realtimeUpdatesEnabled: true)
    // highlight-next-line
    .with(accessToken: "your_access_token")
    .with(settingsEnabled: true)
