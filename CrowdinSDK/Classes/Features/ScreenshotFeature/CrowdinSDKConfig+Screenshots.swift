//
//  CrowdinSDKConfig+Screenshots.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 6/1/19.
//

import Foundation

extension CrowdinSDKConfig {
    // Screenshot feature config
    private static var crowdinScreenshotsConfig: CrowdinScreenshotsConfig? = nil
    
    var crowdinScreenshotsConfig: CrowdinScreenshotsConfig? {
        get {
            return CrowdinSDKConfig.crowdinScreenshotsConfig
        }
        set {
            CrowdinSDKConfig.crowdinScreenshotsConfig = newValue
        }
    }
    
    public func with(crowdinScreenshotsConfig: CrowdinScreenshotsConfig) -> Self {
        self.crowdinScreenshotsConfig = crowdinScreenshotsConfig
        return self
    }
}
