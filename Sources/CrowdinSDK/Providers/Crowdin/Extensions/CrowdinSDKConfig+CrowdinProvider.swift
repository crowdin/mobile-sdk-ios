//
//  CrowdinSDKConfig+CrowdinProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 9/30/19.
//

import Foundation

extension CrowdinSDKConfig {
    // Crowdin provider configuration
    private static var crowdinProviderConfig: CrowdinProviderConfig? = nil
    // Realtime updates
    var crowdinProviderConfig: CrowdinProviderConfig? {
        get {
            return Self.crowdinProviderConfig
        }
        set {
            Self.crowdinProviderConfig = newValue
        }
    }

    /// Method for setting provider configuration object.
    ///
    /// - Parameter crowdinProviderConfig: Crowdin provider configuration object.
    /// - Returns: Same object instance with updated crowdinProviderConfig.
    public func with(crowdinProviderConfig: CrowdinProviderConfig) -> Self {
        self.crowdinProviderConfig = crowdinProviderConfig
        return self
    }

    static func resetStoredConfig() {
        Self.crowdinProviderConfig = nil
    }

    var enterprise: Bool { crowdinProviderConfig?.organizationName != nil }
}
