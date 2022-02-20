//
//  ManifestManager.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 11.05.2020.
//

import Foundation

class ManifestManager {
    let hash: String
    
    var files: [String]?
    var timestamp: TimeInterval?
    var languages: [String]?
    var customLanguages: [CustomLangugage]?
    
    var contentDeliveryAPI: CrowdinContentDeliveryAPI
    
    init(hash: String) {
        self.hash = hash
        self.contentDeliveryAPI = CrowdinContentDeliveryAPI(hash: hash)
        ManifestManager.manifestMap[self.hash] = self
    }
    
    fileprivate static var manifestMap: [String: ManifestManager] = [:]
    
    class func manifest(for hash: String) -> ManifestManager? {
        return manifestMap[hash]
    }
    
    var iOSLanguages: [String] {
        return self.languages?.compactMap({ self.iOSLanguageCode(for: $0) }) ?? []
    }
    
    func download(completion: @escaping () -> Void) {
        contentDeliveryAPI.getManifest { manifest, timestamp, error in
            if let manifest = manifest {
                self.files = manifest.files
                self.timestamp = manifest.timestamp
                self.languages = manifest.languages
                self.customLanguages = manifest.customLanguages
                completion()
            } else if let error = error {
                LocalizationUpdateObserver.shared.notifyError(with: [error])
                completion()
            } else {
                LocalizationUpdateObserver.shared.notifyError(with: [NSError(domain: "Unknown error while downloading manifest", code: defaultCrowdinErrorCode, userInfo: nil)])
                completion()
            }
        }
    }
}
