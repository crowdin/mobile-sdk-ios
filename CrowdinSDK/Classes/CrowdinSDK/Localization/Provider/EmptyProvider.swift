//
//  EmptyProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/2/19.
//

import Foundation

class EmptyProvider: LocalizationProvider {
    var localization: String
    var localizationDict: [String : String] = [:]
    var localizations: [String] = []
    required init(localization: String) { self.localization = localization }
    func deintegrate() { }
}
