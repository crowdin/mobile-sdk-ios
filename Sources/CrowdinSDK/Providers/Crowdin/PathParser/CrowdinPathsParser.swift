//
//  CrowdinPathsParser.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/10/19.
//

import Foundation

fileprivate let enLocale = Locale(identifier: "en-GB")

fileprivate enum Paths: String {
    case language = "%language%"
    case locale = "%locale%"
    case localeWithUnderscore = "%locale_with_underscore%"
    case osxCode = "%osx_code%"
    case osxLocale = "%osx_locale%"
    case twoLettersCode = "%two_letters_code%"
    
    static var all: [Paths] = [.language, .locale, .localeWithUnderscore, .osxCode, .osxLocale, .twoLettersCode]
    
    func value(for localization: String) -> String {
        guard let language = CrowdinSupportedLanguages.shared.crowdinSupportedLanguage(for: localization) else { return "" }
        switch self {
        case .language:
            return language.name
        case .locale:
            return language.locale
        case .localeWithUnderscore:
            return language.locale.replacingOccurrences(of: "-", with: "_")
        case .osxCode:
            return language.osxCode
        case .osxLocale:
            return language.osxLocale
        case .twoLettersCode:
            return language.twoLettersCode
        }
    }
}

class CrowdinPathsParser {
    static let shared = CrowdinPathsParser()
    
	func parse(_ path: String, localization: String) -> String {
        var resultPath = path
        if self.containsCustomPath(path) {
            Paths.all.forEach { (path) in
                resultPath = resultPath.replacingOccurrences(of: path.rawValue, with: path.value(for: localization))
            }
        } else {
            // Add localization code to file name
            let crowdinLocalization = CrowdinSupportedLanguages.shared.crowdinLanguageCode(for: localization) ?? localization
            resultPath = "/\(crowdinLocalization)\(path)"
        }
        return resultPath
    }
    
    func containsCustomPath(_ filePath: String) -> Bool {
        var contains = false
        Paths.all.forEach { (path) in
            if filePath.contains(path.rawValue) {
                contains = true
                return
            }
        }
        return contains
    }
}
