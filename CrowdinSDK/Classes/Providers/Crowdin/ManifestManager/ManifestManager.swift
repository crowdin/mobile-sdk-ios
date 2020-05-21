//
//  ManifestManager.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 11.05.2020.
//

import Foundation

class ManifestManager {
    fileprivate static var shared: ManifestManager?
    
    var hash: String
    
    var files: [String]
    var timestamp: TimeInterval?
    var languages: [String]?
    
    var contentDeliveryAPI: CrowdinContentDeliveryAPI
    
    init(hash: String) {
        self.hash = hash
        self.contentDeliveryAPI = CrowdinContentDeliveryAPI(hash: hash)
        let manifest = contentDeliveryAPI.getManifestSync()
        self.files = manifest?.files ?? []
        self.timestamp = manifest?.timestamp
        self.languages = manifest?.languages
    }
    
    static func shared(for hash: String) -> ManifestManager {
        if let shared = shared, shared.hash == hash {
            return shared
        } else {
            let manifestManager = ManifestManager(hash: hash)
            shared = manifestManager
            return manifestManager
        }
    }
    
    var iOSLanguages: [String] {
        return self.languages?.compactMap({ CrowdinSupportedLanguages.shared.iOSLanguageCode(for: $0) }) ?? []
    }
}
