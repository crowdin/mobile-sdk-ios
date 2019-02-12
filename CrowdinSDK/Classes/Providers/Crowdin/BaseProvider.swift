//
//  BaseProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/13/19.
//

import Foundation

protocol BaseProviderProtocol {
    var strings: [String: String] { get set }
    var plurals: NSDictionary { get set }
    init(strings: [String: String], plurals: NSDictionary)
    func deintegrate()
    func set(strings: [String: String])
    func set(plurals: NSDictionary)
}

class BaseProvider: BaseProviderProtocol {
    // Public
    var strings: [String: String]
    var plurals: NSDictionary
    // Private
    var pluralsBundle: DictionaryBundle?
    
    required init(strings: [String: String], plurals: NSDictionary) {
        self.strings = strings
        self.plurals = plurals
        
        self.setupPluralsBundle()
    }
    
    func deintegrate() {
        pluralsBundle?.remove()
    }
    
    // Setters
    func set(strings: [String: String]) {
        self.strings = strings
    }
    
    func set(plurals: NSDictionary) {
        self.plurals = plurals
        self.setupPluralsBundle()
    }
    
    // Setup plurals bundle
    func setupPluralsBundle() {
        self.pluralsBundle = DictionaryBundle(name: "Plurals", fileName: "Localizable.stringsdict", stringsDictionary: self.plurals)
    }
    
    // Localization methods
    public func localizedString(for key: String) -> String? {
        let string = self.pluralsBundle?.bundle.swizzled_LocalizedString(forKey: key, value: nil, table: nil)
        if string != key {
            return string
        }
        return self.strings[key]
    }
    
    public func keyForString(_ text: String) -> String? {
        let key = strings.first(where: { $1 == text })?.key
        return key
    }
}
