let crowdinProviderConfig = CrowdinProviderConfig(hashString: "{your_distribution_hash}",
    sourceLanguage: "{source_language}",
    organizationName: "{organization_name}") // Optional. Required for Enterprise only

var loginConfig: CrowdinLoginConfig
do {
    loginConfig = try CrowdinLoginConfig(clientId: "{client_id}",
       clientSecret: "{client_secret}",
       scope: "project",
       redirectURI: "{redirectURI}")
} catch {
    print(error)
    // CrowdinLoginConfig initialization error handling
}

let crowdinSDKConfig = CrowdinSDKConfig.config()
    .with(crowdinProviderConfig: crowdinProviderConfig)
    .with(realtimeUpdatesEnabled: true)
    .with(loginConfig: loginConfig)
    .with(settingsEnabled: true)

CrowdinSDK.startWithConfig(crowdinSDKConfig, completion: {
    // SDK is ready to use, put code to change language, etc. here
})
