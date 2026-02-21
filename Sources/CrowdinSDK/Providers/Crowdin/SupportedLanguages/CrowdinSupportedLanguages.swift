//
//  CrowdinSupportedLanguages.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/26/19.
//

import Foundation

class CrowdinSupportedLanguages {
    /// Serial queue for thread-safe access to mutable state
    private let queue = DispatchQueue(label: "com.crowdin.sdk.supportedLanguages", attributes: [])
    private let fileTimestampStorage: FileTimestampStorage
    
    fileprivate enum Strings: String {
        case supportedLanguages = "SupportedLanguages"
        case crowdin = "Crowdin"
    }

    fileprivate enum Keys: String {
        case etag = "CrowdinSupportedLanguages.etag"
        case lastUpdatedDate = "CrowdinSupportedLanguages.lastUpdatedDate"
    }

    fileprivate enum TimestampKeys {
        static let localization = "supportedLanguages"
        static let filePath = "languages.json"
    }

    fileprivate var filePath: String {
        // swiftlint:disable line_length
        return CrowdinFolder.shared.path + String.pathDelimiter + Strings.crowdin.rawValue + String.pathDelimiter + Strings.supportedLanguages.rawValue + hash + FileType.json.extension
    }

    fileprivate var etag: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.etag.rawValue + hash)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: Keys.etag.rawValue + hash)
        }
    }
    
    let hash: String
    
    var loaded: Bool {
        queue.sync { _supportedLanguages != nil }
    }
    
    private var _loading = false
    var loading: Bool {
        get { queue.sync { _loading } }
        set { queue.sync { _loading = newValue } }
    }

    fileprivate var _completions: [() -> Void] = []
    fileprivate var _errors: [(Error) -> Void] = []
    private var pendingManifestTimestamp: TimeInterval?

    private var _supportedLanguages: [CrowdinLanguage]?
    var supportedLanguages: [CrowdinLanguage]? {
        get {
            queue.sync { _supportedLanguages }
        }
        set {
            queue.sync {
                _supportedLanguages = newValue
                saveSupportedLanguages()
            }
        }
    }

    init(hash: String, fileTimestampStorage: FileTimestampStorage) {
        self.hash = hash
        self.fileTimestampStorage = fileTimestampStorage
        self.migrate()
        self.readSupportedLanguages()
    }
    
    private func migrate() {
        // Clear old UserDefaults
        UserDefaults.standard.removeObject(forKey: Keys.lastUpdatedDate.rawValue)
        UserDefaults.standard.synchronize()
        
        // Only remove legacy (pre-hash) supported languages cache files.
        // Legacy files have the pattern "SupportedLanguages.json" (without a hash).
        let legacyFileName = Strings.supportedLanguages.rawValue + FileType.json.extension
        let folderPath = CrowdinFolder.shared.path + String.pathDelimiter + Strings.crowdin.rawValue
        let legacyFilePath = folderPath + String.pathDelimiter + legacyFileName
        try? FileManager.default.removeItem(atPath: legacyFilePath)
    }

    func updateSupportedLanguagesIfNeeded(manifestTimestamp: TimeInterval?, completion: (() -> Void)? = nil, error: ((Error) -> Void)? = nil) {
        enum Action {
            case start
            case wait
            case completeImmediately
        }

        let decision: (action: Action, shouldCleanup: Bool) = queue.sync {
            if let completion = completion { _completions.append(completion) }
            if let error = error { _errors.append(error) }

            if _loading { return (.wait, false) }

            let cachedTimestamp = fileTimestampStorage.timestamp(for: TimestampKeys.localization, filePath: TimestampKeys.filePath)
            if let manifestTimestamp = manifestTimestamp {
                if cachedTimestamp == manifestTimestamp, _supportedLanguages != nil {
                    return (.completeImmediately, false)
                }
                let shouldCleanup = cachedTimestamp != manifestTimestamp
                if shouldCleanup {
                    _supportedLanguages = nil
                }
                _loading = true
                pendingManifestTimestamp = manifestTimestamp
                return (.start, shouldCleanup)
            }

            if _supportedLanguages != nil {
                return (.completeImmediately, false)
            }

            _loading = true
            pendingManifestTimestamp = nil
            return (.start, false)
        }

        switch decision.action {
        case .wait:
            return
        case .completeImmediately:
            completeWithoutDownload()
            return
        case .start:
            if decision.shouldCleanup {
                clearCachedSupportedLanguages()
            }
            startDownload()
        }
    }

    func downloadSupportedLanguages(completion: (() -> Void)? = nil, error: ((Error) -> Void)? = nil) {
        updateSupportedLanguagesIfNeeded(manifestTimestamp: nil, completion: completion, error: error)
    }

    func clearCache() {
        queue.sync {
            _errors.removeAll()
            _completions.removeAll()
            _loading = false
            pendingManifestTimestamp = nil
        }
        clearCachedSupportedLanguages()
    }

    private func startDownload() {
        let urlString = "https://distributions.crowdin.net/\(hash)/languages.json"
        guard let url = URL(string: urlString) else {
            notifyError(NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        if let etag = self.etag {
            request.addValue(etag, forHTTPHeaderField: "If-None-Match")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { [weak self] data, response, taskError in
            guard let self = self else { return }
            
            if let taskError = taskError {
                self.notifyError(taskError)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self.notifyError(NSError(domain: "Invalid Response", code: 0, userInfo: nil))
                return
            }
            
            if httpResponse.statusCode == 304 {
                self.notifySuccess(nil)
                return
            }
            
            guard let data = data, httpResponse.statusCode == 200 else {
                let message = "Bad Status Code: \(httpResponse.statusCode). URL: \(urlString)"
                self.notifyError(NSError(domain: message, code: httpResponse.statusCode, userInfo: nil))
                return
            }
            
            if let etag = httpResponse.allHeaderFields["Etag"] as? String {
                self.etag = etag
            }
            
            do {
                let languagesMap = try JSONDecoder().decode([String: DistributionLanguage].self, from: data)
                let languages: [DistributionLanguage] = languagesMap.map { (key, value) in
                    var lang = value
                    lang.id = key
                    return lang
                }
                self.notifySuccess(languages)
            } catch {
                self.notifyError(error)
            }
        }
        task.resume()
    }

    private func clearCachedSupportedLanguages() {
        try? FileManager.default.removeItem(atPath: filePath)
        etag = nil
        fileTimestampStorage.updateTimestamp(for: TimestampKeys.localization, filePath: TimestampKeys.filePath, timestamp: nil)
        fileTimestampStorage.saveTimestamps()
        queue.sync { _supportedLanguages = nil }
    }

    private func completeWithoutDownload() {
        let callbacks: [() -> Void] = queue.sync {
            let completions = self._completions
            self._errors.removeAll()
            self._completions.removeAll()
            self._loading = false
            self.pendingManifestTimestamp = nil
            return completions
        }

        DispatchQueue.main.async {
            callbacks.forEach { $0() }
        }
    }
    
    private func notifyError(_ error: Error) {
        let callbacks: [(Error) -> Void] = queue.sync {
             let errors = self._errors
             self._errors.removeAll()
             self._completions.removeAll()
             self._loading = false
             self.pendingManifestTimestamp = nil
             return errors
        }
        
        CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .error, message: "Failed to download supported languages: \(error.localizedDescription)"))
        DispatchQueue.main.async {
            callbacks.forEach { $0(error) }
        }
    }
    
    private func notifySuccess(_ languages: [CrowdinLanguage]?) {
        let manifestTimestamp = pendingManifestTimestamp
        let callbacks: [() -> Void] = queue.sync {
            if let languages = languages {
                self._supportedLanguages = languages
                self.saveSupportedLanguages()
            } else if self._supportedLanguages == nil {
                // On 304 (Not Modified), load from cache if we don't have it in memory yet
                let cachedData = try? Data(contentsOf: URL(fileURLWithPath: self.filePath))
                if let data = cachedData {
                    self._supportedLanguages = try? JSONDecoder().decode([DistributionLanguage].self, from: data)
                }
            }
            let completions = self._completions
            self._errors.removeAll()
            self._completions.removeAll()
            self._loading = false
            self.pendingManifestTimestamp = nil
            return completions
        }

        if let manifestTimestamp = manifestTimestamp {
            fileTimestampStorage.updateTimestamp(for: TimestampKeys.localization, filePath: TimestampKeys.filePath, timestamp: manifestTimestamp)
            fileTimestampStorage.saveTimestamps()
        }
        
        CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: "Download supported languages success"))
        DispatchQueue.main.async {
            callbacks.forEach { $0() }
        }
    }

    fileprivate func saveSupportedLanguages() {
        // Read the current supported languages on the serial queue for thread safety
        let currentLanguages: [CrowdinLanguage]? = queue.sync { _supportedLanguages }
        
        guard let crowdlanguages = currentLanguages else { return }
        
        // Cast each element individually to DistributionLanguage. A direct cast from
        // [CrowdinLanguage] to [DistributionLanguage] will always fail for existential arrays.
        let distributionLanguages = crowdlanguages.compactMap { $0 as? DistributionLanguage }
        
        // Ensure all elements were successfully cast; if not, avoid writing a partial cache.
        guard distributionLanguages.count == crowdlanguages.count,
              let data = try? JSONEncoder().encode(distributionLanguages) else { return }
        
        try? data.write(to: URL(fileURLWithPath: filePath), options: Data.WritingOptions.atomic)
    }

    fileprivate func readSupportedLanguages() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { return }
        let languages = try? JSONDecoder().decode([DistributionLanguage].self, from: data)
        queue.sync {
            _supportedLanguages = languages
        }
    }

    static func clearAllCaches() {
        let folderPath = CrowdinFolder.shared.path + String.pathDelimiter + Strings.crowdin.rawValue
        if let files = try? FileManager.default.contentsOfDirectory(atPath: folderPath) {
            for file in files where file.starts(with: Strings.supportedLanguages.rawValue) {
                let fullPath = folderPath + String.pathDelimiter + file
                try? FileManager.default.removeItem(atPath: fullPath)
            }
        }

        let defaults = UserDefaults.standard
        let keysToRemove = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(Keys.etag.rawValue) }
        keysToRemove.forEach { defaults.removeObject(forKey: $0) }
        defaults.synchronize()
    }
}

// MARK: - Internal Model

struct DistributionLanguage: Codable, CrowdinLanguage {
    var id: String = ""
    let name: String
    let twoLettersCode: String
    let threeLettersCode: String
    let locale: String
    let localeWithUnderscore: String
    let androidCode: String
    let osxCode: String
    let osxLocale: String

    enum CodingKeys: String, CodingKey {
        case name
        case twoLettersCode = "two_letters_code"
        case threeLettersCode = "three_letters_code"
        case locale
        case localeWithUnderscore = "locale_with_underscore"
        case androidCode = "android_code"
        case osxCode = "osx_code"
        case osxLocale = "osx_locale"
    }
}
