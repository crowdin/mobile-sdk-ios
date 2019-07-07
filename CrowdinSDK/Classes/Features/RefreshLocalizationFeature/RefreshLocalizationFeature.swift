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
        Localization.current.provider.refreshLocalization()
    }
}
