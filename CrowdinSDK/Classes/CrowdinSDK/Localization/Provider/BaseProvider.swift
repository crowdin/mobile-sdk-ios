//
//  BaseProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/13/19.
//

import Foundation

open class BaseLocalizationProvider: LocalizationProvider {
    public var localization: String
    public var localizations: [String]
    
    // Public
    public var strings: [AnyHashable : Any]
    public var plurals: [AnyHashable : Any]
    // Private
    var pluralsBundle: DictionaryBundle?
    var localizationStrings: [String : String]
    
    public init() {
        self.strings = [:]
        self.plurals = [:]
        self.localization = Bundle.main.preferredLanguages.first ?? "en"
        self.localizations = []
        self.localizationStrings = self.strings[localization] as? [String : String] ?? [:]
        self.setupPluralsBundle()
    }
    
    public required init(localizations: [String], strings: [String : String], plurals: [AnyHashable : Any]) {
        self.strings = strings
        self.plurals = plurals
        self.localization = Bundle.main.preferredLanguages.first ?? "en"
        self.localizations = localizations
        self.localizationStrings = self.strings[localization] as? [String : String] ?? [:]
        self.setupPluralsBundle()
    }
    
    public func deintegrate() {
        pluralsBundle?.remove()
    }
    
    // Setters
    public func set(strings: [AnyHashable: Any]) {
        self.strings = strings
        self.setupLocalizationStrings()
    }
    
    public func set(plurals: [AnyHashable: Any]) {
        self.plurals = plurals
        self.setupPluralsBundle()
    }
    
    public func set(localization: String?) {
        self.localization = localization ?? Bundle.main.preferredLanguages.first ?? "en"
        self.setupLocalizationStrings()
    }
    
    // Setup plurals bundle
    func setupPluralsBundle() {
        self.pluralsBundle = DictionaryBundle(name: "Plurals", fileName: "Localizable.stringsdict", stringsDictionary: self.plurals)
    }
    
    func setupLocalizationStrings() {
        self.localizationStrings = self.strings[localization] as? [String : String] ?? [:]
    }
    
    // Localization methods
    public func localizedString(for key: String) -> String? {
        let string = self.pluralsBundle?.bundle.swizzled_LocalizedString(forKey: key, value: nil, table: nil)
        if string != key {
            return string
        }
        return self.localizationStrings[key]
    }
    
    public func keyForString(_ text: String) -> String? {
        let key = localizationStrings.first(where: { $1 == text })?.key
        return key
    }
}
