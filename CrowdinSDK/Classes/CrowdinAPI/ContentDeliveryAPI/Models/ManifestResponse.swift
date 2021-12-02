//
//  ManifestResponse.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 03.11.2019.
//

import Foundation

struct ManifestResponse: Codable {
    public let files: [String]
    public let timestamp: TimeInterval?
    public let languages: [String]?
    public let responseCustomLanguages: [String: ManifestResponseCustomLangugage]?    
    
    enum CodingKeys: String, CodingKey {
        case files
        case timestamp
        case languages
        case responseCustomLanguages = "custom_languages"
    }

    public init(files: [String], timestamp: TimeInterval, languages: [String]?, responseCustomLanguages: [String: ManifestResponseCustomLangugage]?) {
        self.files = files
        self.timestamp = timestamp
        self.languages = languages
        self.responseCustomLanguages = responseCustomLanguages
    }
    
    // MARK: - ManifestResponseCustomLangugage
    struct ManifestResponseCustomLangugage: Codable {
        let locale: String
        let twoLettersCode: String
        let threeLettersCode: String
        let localeWithUnderscore: String
        let androidCode: String
        let osxCode: String
        let osxLocale: String

        enum CodingKeys: String, CodingKey {
            case twoLettersCode = "two_letters_code"
            case threeLettersCode = "three_letters_code"
            case locale
            case localeWithUnderscore = "locale_with_underscore"
            case androidCode = "android_code"
            case osxCode = "osx_code"
            case osxLocale = "osx_locale"
        }
    }
}
