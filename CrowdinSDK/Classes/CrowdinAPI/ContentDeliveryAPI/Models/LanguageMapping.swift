//
//  LanguageMapping.swift
//  CrowdinSDK
//
//  Created by Nazar Yavornytskyy on 4/13/21.
//

import Foundation

public struct LangMapping: Codable {
    
    var languagesMapping: [LanguageMapping] = []
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dictionary = try container.decode([String : PathTestPattern].self)
        
        dictionary.forEach { key, value in
            let languageMapping = LanguageMapping(lang: key, patterns: value.patterns)
            languagesMapping.append(languageMapping)
        }
    }
}

struct LanguageMapping: Encodable {
    
    public let lang: String
    public var patterns: [PathPattern] = []
    
    init(lang: String, patterns: [PathPattern]) {
        self.lang = lang
        self.patterns = patterns
    }
}

struct PathPattern: Encodable {
    
    public var pattern: String
    public var customCode: String
    
    init(pattern: String, customCode: String) {
        self.pattern = pattern
        self.customCode = customCode
    }
}

struct PathTestPattern: Codable {
    
    public var patterns: [PathPattern] = []
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dictionary = try container.decode([String : String].self)
        
        dictionary.forEach { key, value in
            patterns.append(PathPattern(pattern: key, customCode: value))
        }
    }
}

struct PathPatternMapping: Codable {
    
    public let language: String?
    public let locale: String?
    public let localeWithUnderscore: String?
    public let osxCode: String?
    public let osxLocale: String?
    public let threeLettersCode: String?
    public let twoLettersCode: String?
    
    enum CodingKeys: String, CodingKey {
        
        case language = "language"
        case locale = "locale"
        case localeWithUnderscore = "locale_with_underscore"
        case osxCode = "osx_code"
        case osxLocale = "osx_locale"
        case threeLettersCode = "three_letters_code"
        case twoLettersCode = "two_letters_code"
    }
    
    func property(value: String) -> String {
        let prop = [
            language, locale, localeWithUnderscore, osxCode, osxLocale, threeLettersCode, twoLettersCode
        ].compactMap { $0 }
        .first { $0 == value }
        
        return prop ?? "unknown"
    }
    
    var patterns: [PathPattern] {
        return [
            language, locale, localeWithUnderscore, osxCode, osxLocale, threeLettersCode, twoLettersCode
        ].compactMap { $0 }
        .map {
            PathPattern(pattern: property(value: $0), customCode: $0)
        }
    }
}
