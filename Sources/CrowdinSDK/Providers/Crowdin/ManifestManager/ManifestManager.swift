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
    /// Dictionary with manifest downloaded status for hashes. Stats only for downloading from server.
    fileprivate var downloadedMap = [String: Bool]()
    /// Dictionary with manifest loaded status for hashes. Status includes loading from hash and loading from server.
    fileprivate var loadedMap = [String: Bool]()
    /// Dictionary with manifest completion handlers array for hashes.
    fileprivate var completionsMap = [String: [() -> Void]]()
    /// Dictionary with manifest managers for hashes.
    fileprivate static var manifestMap = [String: ManifestManager]()
    
    private var minimumManifestUpdateInterval: TimeInterval
    
    private var lastManifestUpdateInterval: TimeInterval? {
        get {
            fileTimestampStorage.timestamp(for: "none", filePath: "manifest.json")
        }
        set {
            fileTimestampStorage.updateTimestamp(for: "none", filePath: "manifest.json", timestamp: newValue)
            fileTimestampStorage.saveTimestamps()
        }
    }
    
    var fileTimestampStorage: FileTimestampStorage
    
    /// Download status of manifest for current hash for current app session. True - after manifest downloaded from crowdin server.
    var downloaded: Bool {
        get {
            downloadedMap[hash] ?? false
        }
        set {
            downloadedMap[hash] = newValue
        }
    }
    
    /// Indicates whether manifest information was loaded from cache.
    var loaded: Bool {
        get {
            loadedMap[hash] ?? false
        }
        set {
            loadedMap[hash] = newValue
        }
    }
    
    /// Status of manifest downloading for current hash
    fileprivate var downloading: Bool {
        get {
            downloadingMap[hash] ?? false
        }
        set {
            downloadingMap[hash] = newValue
        }
    }
    
    let hash: String
    let sourceLanguage: String
    let organizationName: String?
    var manifest: ManifestResponse?

    var manifestURL: String?
    var contentDeliveryAPI: CrowdinContentDeliveryAPI
    var crowdinSupportedLanguages: CrowdinSupportedLanguages

    fileprivate init(hash: String, sourceLanguage: String, organizationName: String?, minimumManifestUpdateInterval: TimeInterval) {
        self.hash = hash
        self.sourceLanguage = sourceLanguage
        self.organizationName = organizationName
        self.minimumManifestUpdateInterval = minimumManifestUpdateInterval
        self.contentDeliveryAPI = CrowdinContentDeliveryAPI(hash: hash)
        self.crowdinSupportedLanguages = CrowdinSupportedLanguages(organizationName: organizationName)
        self.fileTimestampStorage = FileTimestampStorage(hash: hash)
        self.load()
        ManifestManager.manifestMap[self.hash] = self
    }

    class func manifest(for hash: String, sourceLanguage: String, organizationName: String?, minimumManifestUpdateInterval: TimeInterval) -> ManifestManager {
        manifestMap[hash] ?? ManifestManager(hash: hash, sourceLanguage: sourceLanguage, organizationName: organizationName, minimumManifestUpdateInterval: minimumManifestUpdateInterval)
    }

    var languages: [String]? { manifest?.languages }
    var files: [String]? { manifest?.files }
    var timestamp: TimeInterval? { manifest?.timestamp }
    var customLanguages: [CustomLangugage] { manifest?.customLanguages ?? [] }
    var mappingFiles: [String] { manifest?.mapping ?? [] }
    var xcstringsLanguage: String { languages?.sorted().first ?? sourceLanguage }

    var iOSLanguages: [String] {
        return self.languages?.compactMap({ self.iOSLanguageCode(for: $0) }) ?? []
    }

    func contentFiles(for language: String) -> [String] {
        guard let crowdinLanguage = crowdinLanguageCode(for: language) else { return [] }
        var files = manifest?.content[crowdinLanguage] ?? []
        if language != xcstringsLanguage {
            let xcstrings = manifest?.content[xcstringsLanguage]?.filter({ $0.isXcstrings }) ?? []
            files.append(contentsOf: xcstrings)
        }
        return files
    }

    func download(completion: @escaping () -> Void) {
        let lastUpdateTimestamp = lastManifestUpdateInterval ?? 0
        let currentTime = Date().timeIntervalSince1970
        let minimumInterval = minimumManifestUpdateInterval
        
        guard currentTime - lastUpdateTimestamp >= minimumInterval else {
            completion()
            return
        }
        
        guard downloaded == false else {
            completion()
            return
        }
        addCompletion(completion: completion, for: hash)
        guard downloading == false else { return }
        downloading = true
        contentDeliveryAPI.getManifest { [weak self] manifest, manifestURL, error in
            guard let self = self else { return }
            if let manifest = manifest {
                self.manifest = manifest
                self.manifestURL = manifestURL
                self.save(manifestResponse: manifest)
                self.loaded = true
                self.downloaded = true
                self.lastManifestUpdateInterval = currentTime
            } else if let error = error {
                LocalizationUpdateObserver.shared.notifyError(with: [error])
            } else {
                LocalizationUpdateObserver.shared.notifyError(with: [NSError(domain: "Unknown error while downloading manifest", code: defaultCrowdinErrorCode, userInfo: nil)])
            }
            self.callCompletions(for: self.hash)
            self.removeCompletions(for: self.hash)
            self.downloading = false
        }
    }

    func hasFileChanged(filePath: String, localization: String) -> Bool {
        guard let currentTimestamp = manifest?.timestamp else { return false }
        return fileTimestampStorage.timestamp(for: localization, filePath: filePath) != currentTimestamp
    }

    private func updateFileTimestamps(manifest: ManifestResponse) {
        for file in manifest.files {
            for language in manifest.languages ?? [] {
                fileTimestampStorage.updateTimestamp(for: language, filePath: file, timestamp: manifest.timestamp ?? 0)
            }
        }
        fileTimestampStorage.saveTimestamps()
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

    private var manifestPath: String { ManifestManager.manifestsPath + hash + (organizationName ?? "") + ".json" }

    static private let manifestsPath = CrowdinFolder.shared.path + "/Manifests/"

    private func save(manifestResponse: ManifestResponse) {
        try? FileManager.default.createDirectory(at: URL(fileURLWithPath: ManifestManager.manifestsPath), withIntermediateDirectories: true, attributes: nil)
        guard let data = try? JSONEncoder().encode(manifestResponse) else { return }
        try? data.write(to: URL(fileURLWithPath: manifestPath))
    }

    private func load() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: manifestPath)) else { return }
        guard let manifestResponse = try? JSONDecoder().decode(ManifestResponse.self, from: data) else { return }
        self.manifest = manifestResponse
        loaded = true
    }

    static func clear() {
        manifestMap.removeAll()
        try? FileManager.default.removeItem(atPath: ManifestManager.manifestsPath)
        FileTimestampStorage.clear()
    }

    func clear() {
        ManifestManager.manifestMap.removeValue(forKey: hash)
        try? FileManager.default.removeItem(atPath: manifestPath)
        fileTimestampStorage.clear()
    }
}
