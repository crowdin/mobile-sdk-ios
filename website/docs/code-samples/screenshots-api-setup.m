CrowdinProviderConfig *crowdinProviderConfig = [[CrowdinProviderConfig alloc] initWithHashString:@"" sourceLanguage:@"" organizationName:@"{organization_name}"];

CrowdinSDKConfig *config = [[[[CrowdinSDKConfig config]
    withCrowdinProviderConfig:crowdinProviderConfig]
    withScreenshotsEnabled:YES]
    // highlight-next-line
    withAccessToken:@"your_access_token"];
