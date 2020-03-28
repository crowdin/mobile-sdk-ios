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
    
    enum CodingKeys: String, CodingKey {
        case files
        case timestamp
    }

    public init(files: [String], timestamp: TimeInterval) {
        self.files = files
        self.timestamp = timestamp
    }
}
