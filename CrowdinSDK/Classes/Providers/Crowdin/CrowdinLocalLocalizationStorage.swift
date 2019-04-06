//
//  CrowdinLocalLocalizationStorage.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/27/19.
//

import Foundation

class CrowdinLocalLocalizationStorage: LocalLocalizationStorage {
    required init(localization: String) {
        self.localization = localization
    }
    // swiftlint:disable force_try
    let localizationFolder: FolderProtocol = try! CrowdinFolder.shared.createFolder(with: Strings.Crowdin.rawValue)
    
    var localization: String {
        didSet {
            self.fetchData()
        }
    }
    
    var localizations: [String] = [] {
        didSet {
            let localizationsFilePath = self.localizationFolder.path + String.pathDelimiter + "localizations" + FileType.plist.extension
            let localizationsFile = DictionaryFile(path: localizationsFilePath)
            localizationsFile.file = [Keys.localizations.rawValue : localizations]
            try? localizationsFile.save()
        }
    }
    
    private var _strings: Atomic<[String: String]> = Atomic([:])
    var strings: [String: String] {
        get {
            return _strings.value
        }
        set {
            _strings.mutate({ $0 = newValue })
            saveLocalization()
        }
    }
    
    private var _plurals: Atomic<[AnyHashable: Any]> = Atomic([:])
    var plurals: [AnyHashable: Any] {
        get {
            return _plurals.value
        }
        set {
            _plurals.mutate({ $0 = newValue })
            saveLocalization()
        }
    }
    
    func fetchData() {
        let localizationFilePath = self.localizationFolder.path + String.pathDelimiter + localization + FileType.plist.extension
        let localizationFile = DictionaryFile(path: localizationFilePath)
        if let strings = localizationFile.file?[Keys.strings.rawValue] as? [String: String] {
            self.strings = strings
        }
        if let plurals = localizationFile.file?[Keys.plurals.rawValue] as? [AnyHashable: Any] {
            self.plurals = plurals
        }
        let localizationsFilePath = self.localizationFolder.path + String.pathDelimiter + "localizations" + FileType.plist.extension
        let localizationsFile = DictionaryFile(path: localizationsFilePath)
        if let localizations = localizationsFile.file?[Keys.localizations.rawValue] as? [String] {
            self.localizations = localizations
        }
    }
    
    func fetchData(completion: LocalizationStorageCompletion) {
        self.fetchData()
        completion(self.localizations, self.strings, self.plurals, [])
    }
    
    func saveLocalization() {
        let localizationFilePath = self.localizationFolder.path + String.pathDelimiter + localization + FileType.plist.extension
        let localizationFile = DictionaryFile(path: localizationFilePath)
        localizationFile.file = [Keys.strings.rawValue : strings, Keys.plurals.rawValue: plurals]
        try? localizationFile.save()
    }
}
