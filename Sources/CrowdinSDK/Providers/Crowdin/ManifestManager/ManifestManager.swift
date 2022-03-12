//
//  ManifestManager.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 11.05.2020.
//

import Foundation

/// Class for managing manifest files: downlaoding, caching, clearing cache.
class ManifestManager {
    /// Dictionary with manifest downloading status for hashes.
    fileprivate var downloadingMap = [String: Bool]()
    fileprivate var downloadedMap = [String: Bool]()
    fileprivate var completionsMap = [String: [() -> Void]]()
    fileprivate static var manifestMap = [String: ManifestManager]()
    
    var downloaded: Bool { downloadedMap[hash] ?? false }
    
    let hash: String
    var files: [String]?
    var timestamp: TimeInterval?
    var languages: [String]?
    var customLanguages: [CustomLangugage]?
    
    var contentDeliveryAPI: CrowdinContentDeliveryAPI
    
    fileprivate init(hash: String) {
        self.hash = hash
        self.contentDeliveryAPI = CrowdinContentDeliveryAPI(hash: hash)
        self.load()
        ManifestManager.manifestMap[self.hash] = self
    }
    
    class func manifest(for hash: String) -> ManifestManager {
        if let manifest = manifestMap[hash] {
            return manifest
        }
        let manifest = ManifestManager(hash: hash)
        return manifest
    }
    
    var iOSLanguages: [String] {
        return self.languages?.compactMap({ self.iOSLanguageCode(for: $0) }) ?? []
    }
    
    func download(completion: @escaping () -> Void) {
        guard downloaded == false else {
            completion()
            return
        }
        guard downloadingMap[hash] != true else {
            addCompletion(completion: completion, for: hash)
            return
        }
        addCompletion(completion: completion, for: hash)
        self.downloadingMap[self.hash] = true
        contentDeliveryAPI.getManifest { [weak self] manifest, timestamp, error in
            guard let self = self else { return }
            if let manifest = manifest {
                self.files = manifest.files
                self.timestamp = manifest.timestamp
                self.languages = manifest.languages
                self.customLanguages = manifest.customLanguages
                self.save(manifestResponse: manifest)
                self.downloadedMap[self.hash] = true
            } else if let error = error {
                LocalizationUpdateObserver.shared.notifyError(with: [error])
            } else {
                LocalizationUpdateObserver.shared.notifyError(with: [NSError(domain: "Unknown error while downloading manifest", code: defaultCrowdinErrorCode, userInfo: nil)])
            }
            self.callCompletions(for: self.hash)
            self.removeCompletions(for: self.hash)
            self.downloadingMap[self.hash] = false
        }
    }
    
    private func addCompletion(completion: @escaping () -> Void, for hash: String) {
        var completions = completionsMap[hash] ?? []
        completions.append(completion)
        completionsMap[hash] = completions
    }
    
    private func removeCompletions(for hash: String) {
        completionsMap.removeValue(forKey: hash)
    }
    
    private func callCompletions(for hash: String) {
        completionsMap[hash]?.forEach({ $0() })
    }
    
    /// Path for current hash manifests file
    private var manifestPath: String { ManifestManager.manifestsPath + hash + ".json" }
    
    /// Root path for manifests files
    static private let manifestsPath = CrowdinFolder.shared.path + "/Manifests/"
    
    private func save(manifestResponse: ManifestResponse) {
        try? FileManager.default.createDirectory(at: URL(fileURLWithPath: ManifestManager.manifestsPath), withIntermediateDirectories: true, attributes: nil)
        guard let data = try? JSONEncoder().encode(manifestResponse) else { return }
        try? data.write(to: URL(fileURLWithPath: manifestPath))
    }
    
    private func load() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: manifestPath)) else { return }
        guard let manifestResponse = try? JSONDecoder().decode(ManifestResponse.self, from: data) else { return }
        files = manifestResponse.files
        timestamp = manifestResponse.timestamp
        languages = manifestResponse.languages
        customLanguages = manifestResponse.customLanguages
    }
    
    /// Removes all cached manifest data files
    static func clear() {
        try? FileManager.default.removeItem(atPath: ManifestManager.manifestsPath)
    }
    
    /// Removes cached manifest data file for current hash
    func clear() {
        try? FileManager.default.removeItem(atPath: manifestPath)
    }
}
