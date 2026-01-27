//
//  CrowdinSupportedLanguages.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/26/19.
//

import Foundation

extension LanguagesResponseData: CrowdinLanguage { }

class CrowdinSupportedLanguages {
    /// Serial queue for thread-safe access to mutable state
    private let queue = DispatchQueue(label: "com.crowdin.sdk.supportedLanguages", attributes: [])
    
    fileprivate enum Strings: String {
        case supportedLanguages = "SupportedLanguages"
        case crowdin = "Crowdin"
    }

    fileprivate enum Keys: String {
        case lastUpdatedDate = "CrowdinSupportedLanguages.lastUpdatedDate"
    }

    fileprivate var filePath: String {
        // swiftlint:disable line_length
        return CrowdinFolder.shared.path + String.pathDelimiter + Strings.crowdin.rawValue + String.pathDelimiter + Strings.supportedLanguages.rawValue + (organizationName ?? "") + FileType.json.extension
    }

    fileprivate var lastUpdatedDate: Date? {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.lastUpdatedDate.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.value(forKey: Keys.lastUpdatedDate.rawValue) as? Date
        }
    }

    let organizationName: String?
    let api: LanguagesAPI
    
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

    private var _supportedLanguages: LanguagesResponse?
    var supportedLanguages: LanguagesResponse? {
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

    init(organizationName: String?) {
        self.organizationName = organizationName
        api = LanguagesAPI(organizationName: organizationName)
        readSupportedLanguages()
        updateSupportedLanguagesIfNeeded()
    }

    func updateSupportedLanguagesIfNeeded() {
        let shouldDownload = queue.sync { () -> Bool in
            guard _supportedLanguages != nil else { return true }
            guard let lastUpdatedDate = lastUpdatedDate else { return true }
            return Date().timeIntervalSince(lastUpdatedDate) > 7 * 24 * 60 * 60 // 1 week
        }
        
        if shouldDownload {
            self.downloadSupportedLanguages()
        }
    }

    func downloadSupportedLanguages(completion: (() -> Void)? = nil, error: ((Error) -> Void)? = nil) {
        let shouldStartDownload = queue.sync { () -> Bool in
            if let completion = completion { _completions.append(completion) }
            if let error = error { _errors.append(error) }
            
            guard !_loading else { return false }
            _loading = true
            return true
        }
        
        guard shouldStartDownload else { return }

        api.getLanguages(limit: 500, offset: 0) { [weak self] (supportedLanguages, error) in
            guard let self = self else { return }
            
            let callbacks: (completions: [() -> Void], errors: [(Error) -> Void]) = self.queue.sync {
                defer {
                    self._completions.removeAll()
                    self._errors.removeAll()
                    self._loading = false
                }
                
                if let error = error {
                    CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .error, message: "Failed to download supported languages with error: \(error.localizedDescription)"))
                    return (self._completions, self._errors)
                }
                
                guard let supportedLanguages = supportedLanguages else {
                    let error = NSError(domain: "Unknown error while downloading supported languages", code: defaultCrowdinErrorCode, userInfo: nil)
                    CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .error, message: "Failed to download supported languages with error: \(error.localizedDescription)"))
                    return (self._completions, self._errors)
                }
                
                self._supportedLanguages = supportedLanguages
                self.lastUpdatedDate = Date()
                self.saveSupportedLanguages()
                CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: "Download supported languages success"))
                
                return (self._completions, [])
            }
            
            // Call callbacks outside the queue to avoid deadlocks
            if let error = error {
                callbacks.errors.forEach({ $0(error) })
                callbacks.completions.forEach({ $0() })
            } else if supportedLanguages == nil {
                let error = NSError(domain: "Unknown error while downloading supported languages", code: defaultCrowdinErrorCode, userInfo: nil)
                callbacks.errors.forEach({ $0(error) })
                callbacks.completions.forEach({ $0() })
            } else {
                callbacks.completions.forEach({ $0() })
            }
        }
    }

    func downloadSupportedLanguagesSync() {
        let semaphore = DispatchSemaphore(value: 0)
        self.downloadSupportedLanguages(completion: {
            semaphore.signal()
        }, error: { _ in
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: .now() + 60)
    }

    fileprivate func saveSupportedLanguages() {
        // This is called from within queue.sync in the supportedLanguages setter
        // so we don't need additional synchronization here
        guard let data = try? JSONEncoder().encode(_supportedLanguages) else { return }
        try? data.write(to: URL(fileURLWithPath: filePath), options: Data.WritingOptions.atomic)
    }

    fileprivate func readSupportedLanguages() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { return }
        let languages = try? JSONDecoder().decode(LanguagesResponse.self, from: data)
        queue.sync {
            _supportedLanguages = languages
        }
    }
}
