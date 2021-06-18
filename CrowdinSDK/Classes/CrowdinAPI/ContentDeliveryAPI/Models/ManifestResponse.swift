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
    public let languageMapping: LangMapping?
    
    enum CodingKeys: String, CodingKey {
        case files
        case timestamp
        case languages
        case languageMapping = "language_mapping"
    }

    public init(files: [String], timestamp: TimeInterval, languages: [String]?, languageMapping: LangMapping?) {
        self.files = files
        self.timestamp = timestamp
        self.languages = languages
        self.languageMapping = languageMapping
    }
}
