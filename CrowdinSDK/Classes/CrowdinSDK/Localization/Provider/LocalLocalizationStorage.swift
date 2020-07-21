//
//  LocalLocalizationStorage.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 6/3/19.
//

import Foundation

/// Protocol for local storage for localization data.
protocol LocalLocalizationStorageProtocol: LocalizationStorageProtocol {
    /// Strings localization files content.
    var strings: [String: String] { get set }
    /// Plurals localization files content.
    var plurals: [AnyHashable: Any] { get set }
}

/// Local localization storage default implementation. Include data fetching and saving locally.
class LocalLocalizationStorage: LocalLocalizationStorageProtocol {
    /// Initialization method.
    ///
    /// - Parameter localization: Current localization.
    init(localization: String) {
        self.localization = localization
        // swiftlint:disable force_try
        self.localizationFolder = try! CrowdinFolder.shared.createFolder(with: Strings.Crowdin.rawValue)
    }
    
    /// Folder used for storing all localization files.
    var localizationFolder: FolderProtocol
    
    /// Current localization.
    var localization: String {
        didSet {
            self.fetchData()
        }
    }
    
    /// List of all available localizations.
    var localizations: [String] {
        return self.localizationFolder.files.filter({ return $0.type == "plist" }).map({ $0.name })
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
    }
    
    func fetchData(completion: LocalizationStorageCompletion, errorHandler: LocalizationStorageError?) {
        self.fetchData()
        completion(self.localizations, self.strings, self.plurals)
    }
    
    func saveLocalization() {
        let localizationFilePath = self.localizationFolder.path + String.pathDelimiter + localization + FileType.plist.extension
        let localizationFile = DictionaryFile(path: localizationFilePath)
        localizationFile.file = [Keys.strings.rawValue : strings, Keys.plurals.rawValue: plurals]
        do {
            try localizationFile.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
