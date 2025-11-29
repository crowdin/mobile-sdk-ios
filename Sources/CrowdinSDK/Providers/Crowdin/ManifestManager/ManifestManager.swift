//
//  ManifestManager.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 11.05.2020.
//

import Foundation

/// Class for managing manifest files: downlaoding, caching, clearing cache.
class ManifestManager {
    /// Serial queue for thread-safe access to mutable state
    let queue = DispatchQueue(label: "com.crowdin.sdk.manifestmanager", attributes: [])
    
    /// Dictionary with manifest state for hashes.
    fileprivate var _state: ManifestState = .none
    fileprivate var state: ManifestState {
        get { _state }
        set { _state = newValue }
    }
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
    var available: Bool {
        queue.sync { _state == .downloaded || _state == .local }
    }
    let hash: String
    let sourceLanguage: String
    let organizationName: String?
    fileprivate var _manifest: ManifestResponse?
    /// Direct access to manifest. External callers should use thread-safe properties (languages, files, etc.)
    /// Internal methods already use queue.sync to protect access to _manifest
    var manifest: ManifestResponse? {
        get { _manifest }
        set { _manifest = newValue }
    }

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

    var languages: [String]? {
        queue.sync { _manifest?.languages }
    }
    
    var files: [String]? {
        queue.sync { _manifest?.files }
    }
    
    var timestamp: TimeInterval? {
        queue.sync { _manifest?.timestamp }
    }
    
    var customLanguages: [CustomLangugage] {
        queue.sync { _manifest?.customLanguages ?? [] }
    }
    
    var mappingFiles: [String] {
        queue.sync { _manifest?.mapping ?? [] }
    }
    
    var xcstringsLanguage: String {
        queue.sync { _manifest?.languages?.first ?? sourceLanguage }
    }

    var iOSLanguages: [String] {
        // Access supportedLanguages outside queue.sync to avoid nested synchronization
        let crowdinLanguages: [CrowdinLanguage] = crowdinSupportedLanguages.supportedLanguages?.data.map({ $0.data }) ?? []
        
        return queue.sync {
            guard let languages = _manifest?.languages else { return [] }
            
            var resolvedLanguages = [String]()
            var unresolvedLanguages = [String]()
            
            let customLaguages: [CrowdinLanguage] = _manifest?.customLanguages ?? []
            let allLangs: [CrowdinLanguage] = crowdinLanguages + customLaguages
            
            // Try to resolve each language through the language mapping
            for language in languages {
                if let resolved = allLangs.first(where: { $0.id == language })?.iOSLanguageCode {
                    resolvedLanguages.append(resolved)
                } else {
                    unresolvedLanguages.append(language)
                }
            }
            
            // For any unresolved languages, use them directly as fallback
            // This handles cases where:
            // 1. The language mapping hasn't loaded yet or failed
            // 2. The language is a simple code like "en" that might not need complex resolution
            // 3. The language is already in iOS format
            resolvedLanguages.append(contentsOf: unresolvedLanguages)
            
            return resolvedLanguages
        }
    }

    func contentFiles(for language: String) -> [String] {
        // Access supportedLanguages outside queue.sync to avoid nested synchronization
        let crowdinLanguages: [CrowdinLanguage] = crowdinSupportedLanguages.supportedLanguages?.data.map({ $0.data }) ?? []
        
        return queue.sync { () -> [String] in
            let customLaguages: [CrowdinLanguage] = _manifest?.customLanguages ?? []
            let allLangs: [CrowdinLanguage] = crowdinLanguages + customLaguages
            
            var crowdinLanguageCandidate = allLangs.first(where: { $0.iOSLanguageCode == language })
            if crowdinLanguageCandidate == nil {
                let alternateiOSLocaleCode = language.replacingOccurrences(of: "_", with: "-")
                crowdinLanguageCandidate = allLangs.first(where: { $0.iOSLanguageCode == alternateiOSLocaleCode })
            }
            if crowdinLanguageCandidate == nil {
                let alternateiOSLocaleCode = language.split(separator: "_").map({ String($0) }).first
                crowdinLanguageCandidate = allLangs.first(where: { $0.iOSLanguageCode == alternateiOSLocaleCode })
            }
            
            guard let crowdinLanguage = crowdinLanguageCandidate else { return [] }
            
            var files = _manifest?.content[crowdinLanguage.id] ?? []
            
             if files.isEmpty {
                 files = _manifest?.content[crowdinLanguage.twoLettersCode] ?? []
             }

             if files.isEmpty {
                 files = _manifest?.content[crowdinLanguage.osxLocale] ?? []
             }
            
            let xcstringsLang = _manifest?.languages?.first ?? sourceLanguage
            if language != xcstringsLang {
                let xcstrings = _manifest?.content[xcstringsLang]?.filter({ $0.isXcstrings }) ?? []
                files.append(contentsOf: xcstrings)
            }
            return files
        }
    }

    func download(completion: @escaping () -> Void) {
        enum DownloadAction { case start, wait, completeImmediately }
        let action: DownloadAction = queue.sync {
            let lastUpdateTimestamp = self.lastManifestUpdateInterval ?? 0
            let currentTime = Date().timeIntervalSince1970
            let minimumInterval = self.minimumManifestUpdateInterval

            // If minimum interval not reached OR already downloaded -> just complete immediately (no new network call)
            if currentTime - lastUpdateTimestamp < minimumInterval || _state == .downloaded {
                return .completeImmediately
            }

            // If already downloading, add completion and wait for active download to finish
            if _state == .downlaoding {
                self.addCompletion(completion: completion, for: self.hash)
                return .wait
            }

            // Start new download
            self.addCompletion(completion: completion, for: self.hash)
            _state = .downlaoding
            return .start
        }

        switch action {
        case .completeImmediately:
            // Nothing to download, call completion directly
            completion()
            return
        case .wait:
            // A download is already in progress; completion will be invoked when that finishes
            return
        case .start:
            break // Proceed to perform download below
        }

        let currentTime = Date().timeIntervalSince1970
        contentDeliveryAPI.getManifest { [weak self] manifest, manifestURL, error in
            guard let self = self else { return }
            let completions: [() -> Void]? = self.queue.sync {
                if let manifest = manifest {
                    self._manifest = manifest
                    self.manifestURL = manifestURL
                    self.save(manifestResponse: manifest)
                    self._state = .downloaded
                    self.lastManifestUpdateInterval = currentTime
                } else if let error = error {
                    LocalizationUpdateObserver.shared.notifyError(with: [error])
                    self._state = .none
                } else {
                    LocalizationUpdateObserver.shared.notifyError(with: [NSError(domain: "Unknown error while downloading manifest", code: defaultCrowdinErrorCode, userInfo: nil)])
                    self._state = .none
                }
                let completions = self.completionsMap[self.hash]
                self.completionsMap.removeValue(forKey: self.hash)
                return completions
            }
            completions?.forEach { $0() }
        }
    }

    func hasFileChanged(filePath: String, localization: String) -> Bool {
        return queue.sync {
            guard let currentTimestamp = _manifest?.timestamp else { return false }
            return fileTimestampStorage.timestamp(for: localization, filePath: filePath) != currentTimestamp
        }
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
        self._manifest = manifestResponse
        self._state = .local
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
