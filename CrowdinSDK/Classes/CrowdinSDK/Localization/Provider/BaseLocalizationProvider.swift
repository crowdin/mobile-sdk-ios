//
//  BaseProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/13/19.
//

import Foundation

open class BaseLocalizationProvider: LocalizationProvider {
    // Public
    public var localization: String
    public var localizations: [String]
    public var strings: [String : String]
    public var plurals: [AnyHashable : Any]
    
    // Private
    var pluralsFolder: Folder
    var pluralsBundle: DictionaryBundle?
    var stringsDataSource: StringsLocalizationDataSource
    var pluralsDataSource: PluralsLocalizationDataSource
    
    public init() {
        self.strings = [:]
        self.plurals = [:]
        self.localization = Bundle.main.preferredLanguages.first ?? defaultLocalization
        self.localizations = []
        self.pluralsFolder = Folder(path: CrowdinFolder.shared.path + String.pathDelimiter + "Plurals")
        self.stringsDataSource = StringsLocalizationDataSource(strings: [:])
        self.pluralsDataSource = PluralsLocalizationDataSource(plurals: [:])
        self.setupPluralsBundle()
    }
    
    public required init(localizations: [String], strings: [String : String], plurals: [AnyHashable : Any]) {
        self.strings = strings
        self.plurals = plurals
        self.localization = Bundle.main.preferredLanguages.first ?? defaultLocalization
        self.localizations = localizations
        self.pluralsFolder = Folder(path: CrowdinFolder.shared.path + String.pathDelimiter + "Plurals")
        self.stringsDataSource = StringsLocalizationDataSource(strings: strings)
        self.pluralsDataSource = PluralsLocalizationDataSource(plurals: plurals)
        self.setupPluralsBundle()
    }
    
    public func deintegrate() {
        try? CrowdinFolder.shared.remove()
        try? pluralsFolder.remove()
        pluralsBundle?.remove()
    }
    
    // Setters
    public func set(strings: [String: String]) {
        self.strings = strings
        self.setupLocalizationStrings()
    }
    
    public func set(plurals: [AnyHashable: Any]) {
        self.plurals = plurals
        self.setupPluralsBundle()
    }
    
    public func set(localization: String?) {
        self.localization = localization ?? Bundle.main.preferredLanguages.first ?? defaultLocalization
        self.setupLocalizationStrings()
    }
    
    // Setup plurals bundle
    func setupPluralsBundle() {
        self.pluralsDataSource = PluralsLocalizationDataSource(plurals: plurals)
		self.pluralsBundle?.remove()
		pluralsFolder.directories.forEach({ try? $0.remove() })
        let localizationFolderName = localization + "-" + UUID().uuidString
        self.pluralsBundle = DictionaryBundle(path: pluralsFolder.path + String.pathDelimiter + localizationFolderName, fileName: "Localizable.stringsdict", dictionary: self.plurals)
    }
    
    func setupLocalizationStrings() {
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
