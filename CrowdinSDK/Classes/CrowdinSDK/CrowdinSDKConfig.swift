//
//  CrowdinSDKConfig.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/9/19.
//

import Foundation

/// Class with all crowdin sdk information needed for initialization.
@objcMembers public class CrowdinSDKConfig: NSObject {
    // Crowdin provider configuration
    var crowdinProviderConfig: CrowdinProviderConfig? = nil
    
    /// Method for new config creation.
    ///
    /// - Returns: New CrowdinSDKConfig object instance.
    public static func config() -> CrowdinSDKConfig {
        return CrowdinSDKConfig()
    }
    
    /// Method for setting provider configuration object.
    ///
    /// - Parameter crowdinProviderConfig: Crowdin provider configuration object.
    /// - Returns: Same object instance with updated crowdinProviderConfig.
    public func with(crowdinProviderConfig: CrowdinProviderConfig) -> Self {
        self.crowdinProviderConfig = crowdinProviderConfig
        return self
    }
}
