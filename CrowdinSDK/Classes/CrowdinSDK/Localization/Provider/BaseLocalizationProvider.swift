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
    var pluralsFolder: Folder
    var pluralsBundle: DictionaryBundle?
    var localizationStrings: [String : String]
    
    public init() {
        self.strings = [:]
        self.plurals = [:]
        self.localization = Bundle.main.preferredLanguages.first ?? "en"
        self.localizations = []
        self.localizationStrings = self.strings[localization] as? [String : String] ?? [:]
        self.pluralsFolder = Folder(path: CrowdinFolder.shared.path + "/" + "Plurals")
        self.setupPluralsBundle()
    }
    
    public required init(localizations: [String], strings: [String : String], plurals: [AnyHashable : Any]) {
        self.strings = strings
        self.plurals = plurals
        self.localization = Bundle.main.preferredLanguages.first ?? "en"
        self.localizations = localizations
        self.localizationStrings = self.strings[localization] as? [String : String] ?? [:]
        self.pluralsFolder = Folder(path: CrowdinFolder.shared.path + "/" + "Plurals")
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
		self.pluralsBundle?.remove()
        
        self.pluralsBundle = DictionaryBundle(path: pluralsFolder.path + "/" + localization, fileName: "Localizable.stringsdict", dictionary: self.plurals)
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
        var key = localizationStrings.first(where: { $1 == text })?.key
        if key == nil {
            key = findKey(in: self.localizationStrings, forText: text)
        }
//        if key == nil, let plurals = self.pluralsBundle?.dictionary {
//            key = findKey(for: plurals)
//        }
        return key
    }
    
    private let formatTypesRegEx: NSRegularExpression = {
        let pattern_int = "(?:h|hh|l|ll|q|z|t|j)?([dioux])" // %d/%i/%o/%u/%x with their optional length modifiers like in "%lld"
        let pattern_float = "[aefg]"
        let position = "([1-9]\\d*\\$)?" // like in "%3$" to make positional specifiers
        let precision = "[-+]?\\d*(?:\\.\\d*)?" // precision like in "%1.2f" or "%012.10"
        let reference = "#@([^@]+)@" // reference to NSStringFormatSpecType in .stringsdict
        do {
            return try NSRegularExpression(pattern: "(?<!%)%\(position)\(precision)(@|\(pattern_int)|\(pattern_float)|[csp]|\(reference))", options: [.caseInsensitive])
        } catch {
            fatalError("Error building the regular expression used to match string formats")
        }
    }()
    
    func findKey(in formatedStrings: [String: String], forText: String) -> String? {
        for (key, value) in formatedStrings {
            let matches = formatTypesRegEx.matches(in: value, options: [], range: NSRange(location: 0, length: value.count))
            guard matches.count > 0 else { continue }
            let ranges = matches.compactMap({ $0.range })
            let nsStringValue = value as NSString
            var components = [String]()
            for index in 0...ranges.count - 1 {
                let range = ranges[index]
                if index == 0 {
                    let string = nsStringValue.substring(with: NSRange(location: 0, length: range.location))
                    components.append(string)
                } else if index == ranges.count - 1 {
                    let location = range.location + range.length
                    let string = nsStringValue.substring(with: NSRange(location: location, length: nsStringValue.length - location))
                    components.append(string)
                } else {
                    let previousRange = ranges[index - 1]
                    let location = previousRange.location + previousRange.length
                    let string = nsStringValue.substring(with: NSRange(location: location, length: range.location - location))
                    components.append(string)
                }
            }
            
            var isIncluded = true
            components.forEach { (component) in
                if !forText.contains(component) {
                    isIncluded = false
                    return
                }
            }
            return isIncluded ? key : nil
        }
        return nil
    }
    
    func findKey(for plurals: [AnyHashable: Any]) -> String? {
//        var dict = plurals
//        dict.keys.forEach({ (key) in
//            var localized = dict[key] as! [AnyHashable: Any]
//            localized.keys.forEach({ (key1) in
//                if key1 as! String == "NSStringLocalizedFormatKey" { return }
//                var value = localized[key1] as! [String: String]
//                value.keys.forEach({ (key) in
//                    guard key != "NSStringFormatSpecTypeKey" else { return }
//                    guard key != "NSStringFormatValueTypeKey" else { return }
//
//                    value[key] = value[key]! + "[\(localization)]"
//                })
//                localized[key1 as! String] = value
//            })
//            dict[key] = localized
//        })
        return nil
    }
}
