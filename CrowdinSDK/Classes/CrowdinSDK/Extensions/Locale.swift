//
//  Locale.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/25/19.
//  Copyright © 2019 Crowdin. All rights reserved.
//

import Foundation

extension Locale {
    enum Keys: String {
        case kCFLocaleLanguageCodeKey
        case kCFLocaleCountryCodeKey
        case kCFLocaleScriptCodeKey
    }
    static var preferredLanguageIdentifiers: [String] {
        return Locale.preferredLanguages.compactMap ({
            let components = Locale.components(fromIdentifier: $0)
            print(components)
            var value = components[Keys.kCFLocaleLanguageCodeKey.rawValue]!
            if let scriptCode = components[Keys.kCFLocaleScriptCodeKey.rawValue] {
                value = value + "-" + scriptCode
            }
            return value
        })
    }
}
