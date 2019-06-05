//
//  BaseProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/13/19.
//

import Foundation

protocol LocalizationProviderProtocol {
    init(localization: String, localStorage: LocalLocalizationStorageProtocol, remoteStorage: RemoteLocalizationStorageProtocol)
    var localStorage: LocalLocalizationStorageProtocol { get }
    var remoteStorage: RemoteLocalizationStorageProtocol { get }
    
    var localization: String { get set }
    var localizations: [String] { get }
    
    func refreshLocalization()
    
    func deintegrate()
    func localizedString(for key: String) -> String?
    func key(for string: String) -> String?
    func values(for string: String, with format: String) -> [Any]?
}

class LocalizationProvider: NSObject, LocalizationProviderProtocol {
    private enum Strings: String {
        case Plurals
        case LocalizableStringsdict = "Localizable.stringsdict"
    }
    // Public
    var localization: String {
        didSet {
            self.localStorage.localization = localization
            self.remoteStorage.localization = localization
            self.refreshLocalization()
        }
    }
    var localStorage: LocalLocalizationStorageProtocol
    var remoteStorage: RemoteLocalizationStorageProtocol
    var localizations: [String] { return localStorage.localizations }
    // Internal
    var strings: [String: String] { return localStorage.strings }
    var plurals: [AnyHashable: Any] { return localStorage.plurals }
    var pluralsFolder: FolderProtocol
    var pluralsBundle: DictionaryBundleProtocol?
    var stringsDataSource: LocalizationDataSourceProtocol
    var pluralsDataSource: LocalizationDataSourceProtocol
    
    required init(localization: String, localStorage: LocalLocalizationStorageProtocol, remoteStorage: RemoteLocalizationStorageProtocol) {
        self.localization = localization
        self.localStorage = localStorage
        self.remoteStorage = remoteStorage
        self.pluralsFolder = Folder(path: CrowdinFolder.shared.path + String.pathDelimiter + Strings.Plurals.rawValue)
        self.stringsDataSource = StringsLocalizationDataSource(strings: [:])
        self.pluralsDataSource = PluralsLocalizationDataSource(plurals: [:])
        super.init()
    }
    
    init(localization: String, localizations: [String], remoteStorage: RemoteLocalizationStorageProtocol) {
        self.localization = localization
        self.localStorage = LocalLocalizationStorage(localization: localization, localizations: localizations)
        self.remoteStorage = remoteStorage
        self.pluralsFolder = Folder(path: CrowdinFolder.shared.path + String.pathDelimiter + Strings.Plurals.rawValue)
        self.stringsDataSource = StringsLocalizationDataSource(strings: [:])
        self.pluralsDataSource = PluralsLocalizationDataSource(plurals: [:])
        super.init()
    }
    
    func deintegrate() {
        try? CrowdinFolder.shared.remove()
        try? pluralsFolder.remove()
        pluralsBundle?.remove()
    }
    
    func refreshLocalization() {
        self.loadLocalLocalization()
        self.fetchLocalization()
    }
    
    // Private method
    func loadLocalLocalization() {
        self.localStorage.localization = localization
        self.localStorage.fetchData { localizations, strings, plurals in
            self.setup(with: localizations, strings: strings, plurals: plurals)
        }
    }
    
    func fetchLocalization() {
        self.remoteStorage.localization = localization
        self.remoteStorage.fetchData { localizations, strings, plurals in
            self.setup(with: localizations, strings: strings, plurals: plurals)
        }
    }
    
    func setup(with localizations: [String]?, strings: [String: String]?, plurals: [AnyHashable: Any]?) {
        if let strings = strings {
            self.localStorage.strings.merge(with: strings)
        }
        if let plurals = plurals {
            self.localStorage.plurals.merge(with: plurals)
        }
        if let localizations = localizations {
            self.localStorage.localizations = localizations
        }
        self.setupStrings()
        self.setupPlurals()
    }
    
    // Setup plurals
    func setupPlurals() {
        self.pluralsDataSource = PluralsLocalizationDataSource(plurals: plurals)
        self.setupPluralsBundle()
    }
    
    func setupPluralsBundle() {
		self.pluralsBundle?.remove()
		pluralsFolder.directories.forEach({ try? $0.remove() })
        let localizationFolderName = localStorage.localization + String.minus + UUID().uuidString
        self.pluralsBundle = DictionaryBundle(path: pluralsFolder.path + String.pathDelimiter + localizationFolderName, fileName: Strings.LocalizableStringsdict.rawValue, dictionary: self.plurals)
    }
    // Setup strings
    func setupStrings() {
        self.stringsDataSource = StringsLocalizationDataSource(strings: strings)
    }
    
    // Localization methods
    func localizedString(for key: String) -> String? {
        var string = self.strings[key]
        if string == nil {
			string = self.pluralsBundle?.bundle.swizzled_LocalizedString(forKey: key, value: nil, table: nil)
        }
        return string
    }
    
    func key(for string: String) -> String? {
        var key = stringsDataSource.findKey(for: string)
        guard key == nil else { return key }
        key = pluralsDataSource.findKey(for: string)
        return key
    }

    func values(for string: String, with format: String) -> [Any]? {
        var values = self.stringsDataSource.findValues(for: string, with: format)
        if values == nil {
            values = self.pluralsDataSource.findValues(for: string, with: format)
        }
        return values
    }
}
