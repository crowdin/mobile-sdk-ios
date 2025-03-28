//
//  ManifestManager.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 11.05.2020.
//

import Foundation

/// Class for managing manifest files: downlaoding, caching, clearing cache.
class ManifestManager {
    /// Dictionary with manifest state for hashes.
    fileprivate var state: ManifestState = .none
    /// Dictionary with manifest completion handlers array for hashes.
    fileprivate var completionsMap = [String: [() -> Void]]()
    /// Dictionary with manifest managers for hashes.
    fileprivate static var manifestMap = [String: ManifestManager]()
    
    private var minimumManifestUpdateInterval: TimeInterval
    
    private var lastManifestUpdateInterval: TimeInterval? {
        get {
            fileTimestampStorage.timestamp(for: "manifest", filePath: "manifest.json")
        }
        set {
            fileTimestampStorage.updateTimestamp(for: "manifest", filePath: "manifest.json", timestamp: newValue)
            fileTimestampStorage.saveTimestamps()
        }
    }
    
    var fileTimestampStorage: FileTimestampStorage
    var available: Bool { state == .downloaded || state == .local }
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
    var xcstringsLanguage: String { languages?.first ?? sourceLanguage }

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
        guard state != .downloaded else {
            completion()
            return
        }
        
        addCompletion(completion: completion, for: hash)
        guard state != .downlaoding else { return }
        state = .downlaoding
        contentDeliveryAPI.getManifest { [weak self] manifest, manifestURL, error in
            guard let self = self else { return }
            if let manifest = manifest {
                self.manifest = manifest
                self.manifestURL = manifestURL
                self.save(manifestResponse: manifest)
                self.state = .downloaded
                self.lastManifestUpdateInterval = currentTime
            } else if let error = error {
                LocalizationUpdateObserver.shared.notifyError(with: [error])
            } else {
                LocalizationUpdateObserver.shared.notifyError(with: [NSError(domain: "Unknown error while downloading manifest", code: defaultCrowdinErrorCode, userInfo: nil)])
            }
            self.callCompletions(for: self.hash)
            self.removeCompletions(for: self.hash)
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

    /// Path for current hash manifests file
    private var manifestPath: String { ManifestManager.manifestsPath + hash + (organizationName ?? "") + ".json" }

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
        self.manifest = manifestResponse
        self.state = .local
    }

    /// Removes all cached manifest data files
    static func clear() {
        manifestMap.removeAll()
        try? FileManager.default.removeItem(atPath: ManifestManager.manifestsPath)
        FileTimestampStorage.clear()
    }

    /// Removes cached manifest data file for current hash
    func clear() {
        ManifestManager.manifestMap.removeValue(forKey: hash)
        try? FileManager.default.removeItem(atPath: manifestPath)
        fileTimestampStorage.clear()
    }
    
    enum ManifestState {
        case none
        case local
        case downlaoding
        case downloaded
    }
}
