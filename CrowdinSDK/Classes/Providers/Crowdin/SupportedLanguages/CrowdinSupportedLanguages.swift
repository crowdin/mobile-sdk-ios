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
    
    var lastUpdatedDate: Date? {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.lastUpdatedDate.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.value(forKey: Keys.lastUpdatedDate.rawValue) as? Date
        }
    }
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
    
    func updateSupportedLanguagesIfNeeded() {
        guard self.supportedLanguages != nil else {
            self.updateSupportedLanguages()
            return
        }
        guard let lastUpdatedDate = lastUpdatedDate else {
            self.updateSupportedLanguages()
            return
        }
        if Date().timeIntervalSince(lastUpdatedDate) > 7 * 24 * 60 * 60 {
            self.updateSupportedLanguages()
        }
    }
    
    func updateSupportedLanguages() {
        api.getLanguages(limit: 500, offset: 0) { (supportedLanguages, error) in
            guard error == nil else { return }
            guard let supportedLanguages = supportedLanguages else { return }
            self.supportedLanguages = supportedLanguages
            self.lastUpdatedDate = Date()
        }
    }
    
    func saveSupportedLanguages() {
        guard let data = try? JSONEncoder().encode(supportedLanguages) else { return }
        try? data.write(to: URL(fileURLWithPath: filePath), options: Data.WritingOptions.atomic)
    }
    
    func readSupportedLanguages() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { return }
        self.supportedLanguages = try? JSONDecoder().decode(LanguagesResponse.self, from: data)
    }
}
