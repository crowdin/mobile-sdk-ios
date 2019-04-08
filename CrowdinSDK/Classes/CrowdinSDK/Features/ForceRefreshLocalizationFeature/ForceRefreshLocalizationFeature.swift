//
//  ForceUpdateFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/8/19.
//

import Foundation

final class ForceRefreshLocalizationFeature: Feature {
    static var enabled: Bool {
        get {
            return shared != nil
        }
        set {
            if newValue {
                shared = ForceRefreshLocalizationFeature()
            } else {
                shared = nil
            }
        }
    }
    static var shared: ForceRefreshLocalizationFeature?
    
    static func refreshLocalization() {
        Localization.current.provider.refreshLocalization()
    }
}
