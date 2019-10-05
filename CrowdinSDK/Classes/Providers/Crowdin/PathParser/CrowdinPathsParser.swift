//
//  CrowdinPathsParser.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/10/19.
//

import Foundation

fileprivate let enLocale = Locale(identifier: "en_GB")

fileprivate enum Paths: String {
    case language = "%language%"
    case locale = "%locale%"
    case localeWithUnderscore = "%locale_with_underscore%"
    case osxCode = "%osx_code%"
    case osxLocale = "%osx_locale%"
    
    static var all: [Paths] = [.language, .locale, .localeWithUnderscore, .osxCode, .osxLocale]
    
    var value: String {
        switch self {
        case .language:
            // swiftlint:disable force_unwrapping
            let languageCode = Locale.current.languageCode!
            return enLocale.localizedString(forLanguageCode: languageCode) ?? .empty
        case .locale:
            let localeWithUnderscore = Locale.current.identifier
            return localeWithUnderscore.replacingOccurrences(of: "_", with: "-")
        case .localeWithUnderscore:
            return Locale.current.identifier
        case .osxCode:
            return Bundle.main.preferredLanguage + FileType.lproj.extension
        case .osxLocale:
            return Bundle.main.preferredLanguage
        }
    }
}

class CrowdinPathsParser {
    static let shared = CrowdinPathsParser()
    
	func parse(_ path: String, localization: String) -> String {
        var resultPath = path
        if self.containsCustomPath(path) {
            Paths.all.forEach { (path) in
                resultPath = resultPath.replacingOccurrences(of: path.rawValue, with: path.value)
            }
        } else {
            // Add localization code to file name
            let crowdinLocalization = CrowdinSupportedLanguages.shared.crowdinLanguageCode(for: localization) ?? localization
            resultPath = "/\(crowdinLocalization)/\(path)"
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
