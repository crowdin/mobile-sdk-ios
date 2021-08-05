//
//  CrowdinSupportedLanguages.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/26/19.
//

import Foundation

extension LanguagesResponseData {
    var iOSLocaleCode: String {
        return self.osxLocale.replacingOccurrences(of: "_", with: "-")
    }
}

protocol SupportedLanguage: Codable {
    var id: String { get }
    var name: String { get }
    var editorCode: String { get }
    var twoLettersCode: String { get }
    var threeLettersCode: String { get }
    var locale: String { get }
    var osxCode: String { get }
    var osxLocale: String { get }
}

extension LanguagesResponseData: SupportedLanguage { }

class CrowdinSupportedLanguages {
    static let shared = CrowdinSupportedLanguages()
    let api = LanguagesAPI()
    
    fileprivate enum Strings: String {
        case SupportedLanguages
        case Crowdin
    }
    fileprivate enum Keys: String {
        case lastUpdatedDate = "CrowdinSupportedLanguages.lastUpdatedDate"
    }
    fileprivate var filePath: String {
        return CrowdinFolder.shared.path + String.pathDelimiter + Strings.Crowdin.rawValue + String.pathDelimiter + Strings.SupportedLanguages.rawValue + FileType.json.extension
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
    var loaded: Bool { return supportedLanguages != nil }
    
    var supportedLanguages: LanguagesResponse? {
        didSet {
            saveSupportedLanguages()
        }
    }
    
    init() {
        readSupportedLanguages()
        updateSupportedLanguagesIfNeeded()
    }
    
    func crowdinLanguageCode(for localization: String) -> String? {
        var language = supportedLanguages?.data.first(where: { $0.data.iOSLocaleCode == localization })
        if language == nil { // This is possible for languages ​​with regions. In case we didn't find Crowdin language mapping, try to get localization code and search again.
            // swiftlint:disable force_unwrapping
            let alternateiOSLocaleCode = localization.split(separator: "-").map({ String($0) }).first!
            language = supportedLanguages?.data.first(where: { $0.data.iOSLocaleCode == alternateiOSLocaleCode })
        }
        return language?.data.id
    }
    
    func crowdinSupportedLanguage(for localization: String) -> SupportedLanguage? {
        var language = supportedLanguages?.data.first(where: { $0.data.iOSLocaleCode == localization })
        if language == nil {
            // This is possible for languages ​​with regions. In case we didn't find Crowdin language mapping, try to replace _ in location code with -
            let alternateiOSLocaleCode = localization.replacingOccurrences(of: "_", with: "-")
            language = supportedLanguages?.data.first(where: { $0.data.iOSLocaleCode == alternateiOSLocaleCode })
        }
        if language == nil {
            // This is possible for languages ​​with regions. In case we didn't find Crowdin language mapping, try to get localization code and search again
            let alternateiOSLocaleCode = localization.split(separator: "-").map({ String($0) }).first!
            language = supportedLanguages?.data.first(where: { $0.data.iOSLocaleCode == alternateiOSLocaleCode })
        }
        return language?.data
    }
    
    func iOSLanguageCode(for crowdinLocalization: String) -> String? {
        return supportedLanguages?.data.first(where: { $0.data.id == crowdinLocalization })?.data.iOSLocaleCode
    }
    
    func updateSupportedLanguagesIfNeeded() {
        guard self.supportedLanguages != nil else {
            self.downloadSupportedLanguages()
            return
        }
        guard let lastUpdatedDate = lastUpdatedDate else {
            self.downloadSupportedLanguages()
            return
        }
        if Date().timeIntervalSince(lastUpdatedDate) > 7 * 24 * 60 * 60 {
            self.downloadSupportedLanguages()
        }
    }
    
    func downloadSupportedLanguages(completion: (() -> Void)? = nil, error: ((Error) -> Void)? = nil) {
        api.getLanguages(limit: 500, offset: 0) { (supportedLanguages, err) in
            if let err = err {
                error?(err)
                return
            }
            guard let supportedLanguages = supportedLanguages else { return }
            self.supportedLanguages = supportedLanguages
            self.lastUpdatedDate = Date()
            CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: "Download supported languages success"))
            completion?()
        }
    }
    
    func downloadSupportedLanguagesSync() {
        let semaphore = DispatchSemaphore(value: 0)
        self.downloadSupportedLanguages {
            semaphore.signal()
        } error: { _ in
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + 60)
    }
    
    fileprivate func saveSupportedLanguages() {
        guard let data = try? JSONEncoder().encode(supportedLanguages) else { return }
        try? data.write(to: URL(fileURLWithPath: filePath), options: Data.WritingOptions.atomic)
    }
    
    fileprivate func readSupportedLanguages() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { return }
        self.supportedLanguages = try? JSONDecoder().decode(LanguagesResponse.self, from: data)
    }
}
