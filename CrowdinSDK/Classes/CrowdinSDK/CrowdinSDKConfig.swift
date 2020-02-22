//
//  CrowdinSDKConfig.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/9/19.
//

import Foundation

/// Class with all crowdin sdk information needed for initialization.
@objcMembers public class CrowdinSDKConfig: NSObject {
    /// Method for new config creation.
    ///
    /// - Returns: New CrowdinSDKConfig object instance.
    public static func config() -> CrowdinSDKConfig {
        return CrowdinSDKConfig()
    }
    
    /// Method for new config creation.
    ///
    /// - Returns: New CrowdinSDKConfig object instance for concrete organization.
    /// - Parameter organizationName: Organization name.
    public static func config(organizationName: String) -> CrowdinSDKConfig {
        return CrowdinSDKConfig(organizationName: organizationName)
    }
    
    var enterprise: Bool { return organizationName != nil }
    
    var organizationName: String? = nil
    
    override init() { }
    
    init(organizationName: String) {
        self.organizationName = organizationName
    }
}
