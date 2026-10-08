//
//  ForceUpdateFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/8/19.
//

import Foundation

protocol RefreshLocalizationFeatureProtocol {
    static func refreshLocalization()
}

final class RefreshLocalizationFeature: RefreshLocalizationFeatureProtocol {
    static func refreshLocalization() {
        if let currentLocalization = Localization.current {
            FileEtagStorage(localization: currentLocalization.provider.localization).clear()
            // Make sure the manifest is re-downloaded even if the update interval has not elapsed yet.
            (currentLocalization.provider.remoteStorage as? CrowdinRemoteLocalizationStorage)?.manifestManager.resetUpdateInterval()
            currentLocalization.provider.refreshLocalization()
        }
    }
}
