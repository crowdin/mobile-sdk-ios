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
    
    fileprivate enum Strings: String {
        case supportedLanguages = "SupportedLanguages"
        case crowdin = "Crowdin"
    }

    fileprivate enum Keys: String {
        case etag = "CrowdinSupportedLanguages.etag"
        case lastUpdatedDate = "CrowdinSupportedLanguages.lastUpdatedDate"
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

    init(hash: String) {
        self.hash = hash
        self.migrate()
        self.readSupportedLanguages()
        self.updateSupportedLanguagesIfNeeded()
    }
    
    private func migrate() {
        // Clear old UserDefaults
        UserDefaults.standard.removeObject(forKey: Keys.lastUpdatedDate.rawValue)
        UserDefaults.standard.synchronize()
        
        let folderPath = CrowdinFolder.shared.path + String.pathDelimiter + Strings.crowdin.rawValue
        if let files = try? FileManager.default.contentsOfDirectory(atPath: folderPath) {
            for file in files where file.starts(with: Strings.supportedLanguages.rawValue) && !file.contains(hash) {
                let fullPath = folderPath + String.pathDelimiter + file
                try? FileManager.default.removeItem(atPath: fullPath)
            }
        }
    }

    func updateSupportedLanguagesIfNeeded() {
        self.downloadSupportedLanguages()
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
    
    private func notifyError(_ error: Error) {
        let callbacks: [(Error) -> Void] = queue.sync {
             let errors = self._errors
             self._errors.removeAll()
             self._completions.removeAll()
             self._loading = false
             return errors
        }
        
        CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .error, message: "Failed to download supported languages: \(error.localizedDescription)"))
        DispatchQueue.main.async {
            callbacks.forEach { $0(error) }
        }
    }
    
    private func notifySuccess(_ languages: [CrowdinLanguage]?) {
        let callbacks: [() -> Void] = queue.sync {
            if let languages = languages {
                self._supportedLanguages = languages
                self.saveSupportedLanguages()
            }
            let completions = self._completions
            self._errors.removeAll()
            self._completions.removeAll()
            self._loading = false
            return completions
        }
        
        CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: "Download supported languages success"))
        DispatchQueue.main.async {
            callbacks.forEach { $0() }
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
        guard let languages = _supportedLanguages as? [DistributionLanguage], 
              let data = try? JSONEncoder().encode(languages) else { return }
        try? data.write(to: URL(fileURLWithPath: filePath), options: Data.WritingOptions.atomic)
    }

    fileprivate func readSupportedLanguages() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { return }
        let languages = try? JSONDecoder().decode([DistributionLanguage].self, from: data)
        queue.sync {
            _supportedLanguages = languages
        }
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
