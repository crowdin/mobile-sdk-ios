CrowdinProviderConfig *crowdinProviderConfig = [[CrowdinProviderConfig alloc]
    initWithHashString:@"{your_distribution_hash}"
    sourceLanguage:@"{source_language}"
    organizationName:@"{organization_name}"];

CrowdinSDKConfig *config = [[[[CrowdinSDKConfig config]
    withCrowdinProviderConfig:crowdinProviderConfig]
    withRealtimeUpdatesEnabled:YES]
    // highlight-next-line
    withAccessToken:@"your_access_token"];
