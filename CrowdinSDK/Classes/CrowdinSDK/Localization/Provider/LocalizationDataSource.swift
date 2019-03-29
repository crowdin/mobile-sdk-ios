//
//  LocalizationDataSource.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/10/19.
//

import Foundation

protocol LocalizationDataSourceProtocol {
    func findKey(for string: String) -> String?
    func findValues(for string: String, with format: String) -> [Any]?
}

class StringsLocalizationDataSource: LocalizationDataSourceProtocol {
    var strings: [String: String]
    
    init(strings: [String: String]) {
        self.strings = strings
    }
    
    func findKey(for string: String) -> String? {
        // Simple strings
        for (key, value) in strings {
            if string == value { return key }
        }
        // Formated strings
        for (key, value) in strings {
            if String.findMatch(for: value, with: string) { return key }
        }
        return nil
    }
    
    func findValues(for string: String, with format: String) -> [Any]? {
        return String.findValues(for: string, with: format)
    }
}

class PluralsLocalizationDataSource: LocalizationDataSourceProtocol {
    var plurals: [AnyHashable: Any]
    
    init(plurals: [AnyHashable: Any]) {
        self.plurals = plurals
    }
    func findKey(for string: String) -> String? {
        return findKeyValues(for: plurals, for: string).key
    }
    
    func findValues(for string: String, with format: String) -> [Any]? {
        return findKeyValues(for: plurals, for: string).values
    }
    
    func findKeyValues(for plurals: [AnyHashable: Any], for text: String) -> (key: String?, values: [Any]?) {
        for (key, plural) in plurals {
            guard let plural = plural as? [AnyHashable: Any] else { continue }
            for(key1, value) in plural {
                guard let strinKey = key1 as? String else { continue }
                if strinKey == "NSStringLocalizedFormatKey" { continue }
                guard let value = value as? [String: String] else { continue }
                for (key2, formatedString) in value {
                    guard key2 != "NSStringFormatSpecTypeKey" else { continue }
                    guard key2 != "NSStringFormatValueTypeKey" else { continue }
                    // As plurals can be simple string then check whether it is equal to text. If not do the same as for formated string.
                    if formatedString == text { return (key as? String, nil) }
                    if String.findMatch(for: formatedString, with: text) {
                        let values = String.findValues(for: text, with: formatedString)
                        return (key as? String, values)
                    }
                }
            }
        }
        return (nil, nil)
    }
}
