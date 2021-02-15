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
        switch self {
        case .language:
            // swiftlint:disable force_unwrapping
            let languageCode = Locale(identifier: localization).languageCode!
            return enLocale.localizedString(forLanguageCode: languageCode) ?? ""
        case .locale:
            return Locale(identifier: localization).identifier.replacingOccurrences(of: "_", with: "-")
        case .localeWithUnderscore:
            return Locale(identifier: localization).identifier.replacingOccurrences(of: "-", with: "_")
        case .osxCode:
            return Locale(identifier: localization).identifier + ".lproj"
        case .osxLocale:
            return Locale(identifier: localization).identifier
        case .twoLettersCode:
            return Locale(identifier: localization).regionCode ?? Locale(identifier: localization).identifier
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
