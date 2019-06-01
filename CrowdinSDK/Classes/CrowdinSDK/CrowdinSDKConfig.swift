//
//  CrowdinSDKConfig.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/9/19.
//

import Foundation

@objcMembers public class CrowdinSDKConfig: NSObject {
    // Crowdin provider configuration
    var crowdinProviderConfig: CrowdinProviderConfig? = nil
    
    public static func config() -> CrowdinSDKConfig {
        return CrowdinSDKConfig()
    }
    
    public func with(crowdinProviderConfig: CrowdinProviderConfig) -> Self {
        self.crowdinProviderConfig = crowdinProviderConfig
        return self
    }
}
