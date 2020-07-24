//
//  CrowdinSDK+CrowdinProvider.swift
//  BaseAPI
//
//  Created by Serhii Londar on 05.12.2019.
//

import Foundation

extension CrowdinSDK {
    /// Initialization method. Uses default CrowdinProvider with initialization values from Info.plist file.
    public class func start() {
        self.startWithConfig(CrowdinSDKConfig.config())
    }
    
    /// Initialization method. Initialize CrowdinProvider with passed parameters.
    ///
    /// - Parameters:
    ///   - hashString: Distribution hash value.
    public class func startWithConfig(_ config: CrowdinSDKConfig) {
        self.config = config
        let crowdinProviderConfig = config.crowdinProviderConfig ?? CrowdinProviderConfig()
        let hash = crowdinProviderConfig.hashString
        let localizations = ManifestManager.shared(for: hash).iOSLanguages
        let localization = Bundle.main.preferredLanguage(with: localizations)
        let remoteStorage = CrowdinRemoteLocalizationStorage(localization: localization, config: crowdinProviderConfig)
        self.startWithRemoteStorage(remoteStorage)
    }
}
