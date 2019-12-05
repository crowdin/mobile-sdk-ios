//
//  CrowdinSDK+CrowdinProvider.swift
//  BaseAPI
//
//  Created by Serhii Londar on 05.12.2019.
//

import Foundation

extension CrowdinSDK {
    /// Initialization method. Initialize CrowdinProvider with passed parameters.
    ///
    /// - Parameters:
    ///   - hashString: Distribution hash value.
    public class func startWithConfig(_ config: CrowdinSDKConfig) {
        self.config = config
        let crowdinProviderConfig = config.crowdinProviderConfig ?? CrowdinProviderConfig()
        let localization = Bundle.main.preferredLanguage(with: crowdinProviderConfig.localizations)
        let remoteStorage = CrowdinRemoteLocalizationStorage(localization: localization, config: crowdinProviderConfig, enterprise: config.enterprise)
        self.setRemoteStorage(remoteStorage, localizations: crowdinProviderConfig.localizations)
        self.initializeLib()
    }
}
