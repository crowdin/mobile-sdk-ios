//
//  ForceUpdateFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/8/19.
//

import Foundation

class ForceRefreshLocalizationFeature {
    var shared: ForceRefreshLocalizationFeature?
    
    static func refreshLocalization() {
        Localization.current.provider.refreshLocalization()
    }
}
