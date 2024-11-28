CrowdinProviderConfig *crowdinProviderConfig = [[CrowdinProviderConfig alloc] initWithHashString:@"" sourceLanguage:@"" organizationName:@"{organization_name}"];

NSError *error;
CrowdinLoginConfig *loginConfig = [[CrowdinLoginConfig alloc]
    initWithClientId:@"{client_id}"
    clientSecret:@"{client_secret}"
    scope:@"project.screenshot"
    error:&error];

if (!error) {
    CrowdinSDKConfig *config = [[[[CrowdinSDKConfig config]
        withCrowdinProviderConfig:crowdinProviderConfig]
        withScreenshotsEnabled:YES]
        withLoginConfig:loginConfig];

    [CrowdinSDK startWithConfig:config completion:^{
        // SDK is ready to use, put code to change language, etc. here
    }];
} else {
    NSLog(@"%@", error.localizedDescription);
    // CrowdinLoginConfig initialization error handling
}
