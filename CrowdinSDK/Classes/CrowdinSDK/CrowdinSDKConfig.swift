//
//  CrowdinSDKConfig.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/9/19.
//

import Foundation

@objcMembers public class CrowdinSDKConfig {
    // Crowdin provider configuration
    var crowdinProviderConfig: CrowdinProviderConfig? = nil
    
    // Screenshot feature
    var screnshotsEnabled: Bool = false
    
    // Realtime updates
    var reatimeUpdatesEnabled: Bool = false
    
    // Interval updates
    var intervalUpdatesEnabled: Bool = false
    var intervalUpdatesInterval: TimeInterval? = nil
    
    // Settings view
    var settingsEnabled: Bool = false
    
    public static func config() -> CrowdinSDKConfig {
        return CrowdinSDKConfig()
    }
    
    public func with(crowdinProviderConfig: CrowdinProviderConfig) -> Self {
        self.crowdinProviderConfig = crowdinProviderConfig
        return self
    }
    
    public func with(screnshotsEnabled: Bool) -> Self {
        self.screnshotsEnabled = screnshotsEnabled
        return self
    }
    
    public func with(reatimeUpdatesEnabled: Bool) -> Self {
        self.reatimeUpdatesEnabled = reatimeUpdatesEnabled
        return self
    }
    
    public func with(intervalUpdatesEnabled: Bool, interval: TimeInterval?) -> Self {
        self.intervalUpdatesEnabled = intervalUpdatesEnabled
        self.intervalUpdatesInterval = interval
        return self
    }
    
    public func with(settingsEnabled: Bool) -> Self {
        self.settingsEnabled = settingsEnabled
        return self
    }
}
