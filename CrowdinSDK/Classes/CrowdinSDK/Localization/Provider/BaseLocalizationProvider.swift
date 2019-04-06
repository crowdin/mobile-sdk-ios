//
//  BaseProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/13/19.
//

import Foundation

@objcMembers open class BaseLocalizationProvider: NSObject, LocalizationProvider {
    private enum Strings: String {
        case Plurals
        case LocalizableStringsdict = "Localizable.stringsdict"
    }
    // Public
    public var localization: String {
        didSet {
            self.localStorage.localization = localization
            self.remoteStorage.localization = localization
            self.refreshLocalization()
        }
    }
    public var localStorage: LocalLocalizationStorage
    public var remoteStorage: RemoteLocalizationStorage
    public var localizations: [String] { return localStorage.localizations }
    // Internal
    var strings: [String: String] { return localStorage.strings }
    var plurals: [AnyHashable: Any] { return localStorage.plurals }
    var pluralsFolder: FolderProtocol
    var pluralsBundle: DictionaryBundleProtocol?
    var stringsDataSource: LocalizationDataSourceProtocol
    var pluralsDataSource: LocalizationDataSourceProtocol
    
    public required init(localization: String, localStorage: LocalLocalizationStorage, remoteStorage: RemoteLocalizationStorage) {
        self.localization = localization
        self.localStorage = localStorage
        self.remoteStorage = remoteStorage
        self.pluralsFolder = Folder(path: CrowdinFolder.shared.path + String.pathDelimiter + Strings.Plurals.rawValue)
        self.stringsDataSource = StringsLocalizationDataSource(strings: [:])
        self.pluralsDataSource = PluralsLocalizationDataSource(plurals: [:])
        super.init()
    }
    
    public func deintegrate() {
        try? CrowdinFolder.shared.remove()
        try? pluralsFolder.remove()
        pluralsBundle?.remove()
    }
    
    // Private method
    func refreshLocalization() {
        self.loadLocalization()
        self.fetchLocalization()
    }
    
    func loadLocalization() {
        self.localStorage.fetchData { localizations, strings, plurals, errors in
            self.setup(with: localizations, strings: strings, plurals: plurals, errors: errors)
        }
    }
    
    func fetchLocalization() {
        self.remoteStorage.fetchData { localizations, strings, plurals, errors in
            self.setup(with: localizations, strings: strings, plurals: plurals, errors: errors)
        }
    }
    
    func setup(with localizations: [String], strings: [String: String], plurals: [AnyHashable: Any], errors: [Error]) {
        if errors.isEmpty {
            self.localStorage.localizations = localizations
            self.localStorage.strings = strings
            self.localStorage.plurals = plurals
            self.setupStrings()
            self.setupPlurals()
            
            CrowdinSDK.reloadUI()
        } else {
            errors.forEach({ print($0.localizedDescription) })
        }
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
    public func localizedString(for key: String) -> String? {
        var string = self.strings[key]
        if string == nil {
			string = self.pluralsBundle?.bundle.swizzled_LocalizedString(forKey: key, value: nil, table: nil)
        }
        return string
    }
    
    public func key(for string: String) -> String? {
        var key = stringsDataSource.findKey(for: string)
        guard key == nil else { return key }
        key = pluralsDataSource.findKey(for: string)
        return key
    }

    public func values(for string: String, with format: String) -> [Any]? {
        var values = self.stringsDataSource.findValues(for: string, with: format)
        if values == nil {
            values = self.pluralsDataSource.findValues(for: string, with: format)
        }
        return values
    }
}
