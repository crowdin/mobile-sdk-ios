//
//  ObjectiveCExample.m
//  CrowdinSDK_Example
//
//  Created by Serhii Londar on 18.08.2020.
//  Copyright © 2020 Crowdin. All rights reserved.
//

#import "ObjectiveCExample.h"
@import CrowdinSDK;

@implementation ObjectiveCExample

- (void)startSDK {
    CrowdinProviderConfig *crowdinProviderConfig = [[CrowdinProviderConfig alloc] initWithHashString:@"53376706833043f14491518106i" sourceLanguage:@"en"];
    CrowdinSDKConfig *config = [[CrowdinSDKConfig config] withCrowdinProviderConfig:crowdinProviderConfig];
    [CrowdinSDK startWithConfig:config completion:^{
            
    }];
    
    __block NSInteger downloadHandlerId = [CrowdinSDK addDownloadHandler:^{
        [CrowdinSDK removeDownloadHandler:downloadHandlerId];
    }];
    
    __block NSInteger errorHandlerId = [CrowdinSDK addErrorUpdateHandler:^(NSArray<NSError *> * _Nonnull errors) {
        for (NSError *error in errors) {
            NSLog(@"%@", error.localizedDescription);
        }
        [CrowdinSDK removeErrorHandler:errorHandlerId];
    }];
}

@end
