//
//  CrowdinSDK+ReatimeUpdates.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 6/1/19.
//

import Foundation

extension CrowdinSDK {
    class func initializeRealtimeUpdatesFeature() {
        guard let config = CrowdinSDK.config else { return }
        let crowdinProviderConfig = config.crowdinProviderConfig ?? CrowdinProviderConfig()
        if config.reatimeUpdatesEnabled {
            let localization = Bundle.main.preferredLanguage(with: crowdinProviderConfig.localizations)
            RealtimeUpdateFeature.shared = RealtimeUpdateFeature(localization: localization, strings: crowdinProviderConfig.stringsFileNames, plurals: crowdinProviderConfig.pluralsFileNames, hash: crowdinProviderConfig.hashString, sourceLanguage: crowdinProviderConfig.sourceLanguage)
        }
    }
}
