//
//  EmptyProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/2/19.
//

import Foundation

class EmptyProvider: LocalizationProvider {
    var localizationCompleted: LocalizationProviderHandler = { }
    required init() { }
    func setLocalization(_ localization: String?) { }
    var localizationDict: [String : String] = [:]
    var localizations: [String] = []
    func deintegrate() { }
}
