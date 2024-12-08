CrowdinProviderConfig *crowdinProviderConfig = [[CrowdinProviderConfig alloc]
    initWithHashString:@"{your_distribution_hash}"
    sourceLanguage:@"{source_language}"
    organizationName:@"{organization_name}"];

NSError *error;
CrowdinLoginConfig *loginConfig = [[CrowdinLoginConfig alloc]
    initWithClientId:@"{client_id}"
    clientSecret:@"{client_secret}"
    scope:@"project"
    error:&error];

if (!error) {
    CrowdinSDKConfig *config = [[[[CrowdinSDKConfig config]
        withCrowdinProviderConfig:crowdinProviderConfig]
        withRealtimeUpdatesEnabled:YES]
        withLoginConfig:loginConfig];

    [CrowdinSDK startWithConfig:config completion:^{
       // SDK is ready to use, put code to change language, etc. here
    }];
} else {
    NSLog(@"%@", error.localizedDescription);
    // CrowdinLoginConfig initialization error handling
}
