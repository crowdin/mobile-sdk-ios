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
    public let content: [String: [String]]
    public let mapping: [String]

    enum CodingKeys: String, CodingKey {
        case files
        case timestamp
        case languages
        case responseCustomLanguages = "custom_languages"
        case content
        case mapping
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        files = try values.decode([String].self, forKey: .files)
        timestamp = try values.decodeIfPresent(TimeInterval.self, forKey: .timestamp)
        languages = try values.decodeIfPresent([String].self, forKey: .languages)
        if let customLanguages = try? values.decodeIfPresent([String : ManifestResponseCustomLangugage].self, forKey: .responseCustomLanguages) {
            // Do not throw error while encode custom_languages
            // Server can return empty array for manifests without language mappings.
            responseCustomLanguages = customLanguages
        } else {
            responseCustomLanguages = nil
        }
        self.content = (try? values.decodeIfPresent([String: [String]].self, forKey: .content)) ?? [String: [String]]()
        self.mapping = (try? values.decodeIfPresent([String].self, forKey: .mapping)) ?? [String]()
    }

    public init(files: [String], timestamp: TimeInterval, languages: [String]?, responseCustomLanguages: [String: ManifestResponseCustomLangugage]?, content: [String: [String]], mapping: [String]) {
        self.files = files
        self.timestamp = timestamp
        self.languages = languages
        self.responseCustomLanguages = responseCustomLanguages
        self.content = content
        self.mapping = mapping
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
