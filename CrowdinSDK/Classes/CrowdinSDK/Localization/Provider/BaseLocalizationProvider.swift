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
        self.localization = Bundle.main.preferredLanguages.first ?? defaultLocalization
        self.localizations = []
        self.localizationStrings = self.strings[localization] as? [String : String] ?? [:]
        self.pluralsFolder = Folder(path: CrowdinFolder.shared.path + String.pathDelimiter + "Plurals")
        self.setupPluralsBundle()
    }
    
    public required init(localizations: [String], strings: [String : String], plurals: [AnyHashable : Any]) {
        self.strings = strings
        self.plurals = plurals
        self.localization = Bundle.main.preferredLanguages.first ?? defaultLocalization
        self.localizations = localizations
        self.localizationStrings = self.strings[localization] as? [String : String] ?? [:]
        self.pluralsFolder = Folder(path: CrowdinFolder.shared.path + String.pathDelimiter + "Plurals")
        self.setupPluralsBundle()
    }
    
    public func deintegrate() {
        try? CrowdinFolder.shared.remove()
        try? pluralsFolder.remove()
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
        self.localization = localization ?? Bundle.main.preferredLanguages.first ?? defaultLocalization
        self.setupLocalizationStrings()
    }
    
    // Setup plurals bundle
    func setupPluralsBundle() {
		self.pluralsBundle?.remove()
		pluralsFolder.directories.forEach({ try? $0.remove() })
        let localizationFolderName = localization + "-" + UUID().uuidString
        self.pluralsBundle = DictionaryBundle(path: pluralsFolder.path + String.pathDelimiter + localizationFolderName, fileName: "Localizable.stringsdict", dictionary: self.plurals)
    }
    
    func setupLocalizationStrings() {
        self.localizationStrings = self.strings[localization] as? [String : String] ?? [:]
    }
    
    // Localization methods
    public func localizedString(for key: String) -> String? {
        var string = self.localizationStrings[key]
        if string == nil {
			string = self.pluralsBundle?.bundle.swizzled_LocalizedString(forKey: key, value: nil, table: nil)
        }
        return string
    }
    
    public func keyForString(_ text: String) -> String? {
        var key = findKey(in: self.localizationStrings, for: text)
        guard key == nil else { return key }
        key = findKey(for: self.plurals, for: text).key
        return key
    }
	
//    https://github.com/mac-cain13/R.swift/blob/master/Sources/RswiftCore/ResourceTypes/StringParam.swift
	func findKey(in strings: [String: String], for text: String) -> String? {
        for (key, value) in strings {
            if findMatch(for: value, with: text) { return key }
        }
        return nil
    }
    
    func findMatch(for localizedString: String, with text: String) -> Bool {
        // Check is it equal:
        if localizedString == text { return true }
        // If not try to parse localized string as formated:
        let matches = formatTypesRegEx.matches(in: localizedString, options: [], range: NSRange(location: 0, length: localizedString.count))
        // If it is not formated string return false.
        guard matches.count > 0 else { return false }
        let ranges = matches.compactMap({ $0.range })
        let nsStringValue = localizedString as NSString
        let components = nsStringValue.splitBy(ranges: ranges)
        for component in components {
            if !text.contains(component) {
                return false
            }
        }
        return true
    }
	
	public func findValues(for string: String, with format: String) -> [Any]? {
		let parts = FormatPart.formatParts(formatString: format)
		let matches = formatTypesRegEx.matches(in: format, options: [], range: NSRange(location: 0, length: format.count))
		guard matches.count > 0 else { return nil }
		let ranges = matches.compactMap({ $0.range })
		let nsStringValue = format as NSString
		let components = nsStringValue.splitBy(ranges: ranges)
		
		let nsStringText = string as NSString
		
		var valueRanges = [NSRange]()
		components.forEach({ valueRanges.append(nsStringText.range(of: $0)) })
        
        guard valueRanges.count > 0 else { return nil }
        
		let values = nsStringText.splitBy(ranges: valueRanges)
        
        guard values.count == parts.count else { return nil }
        
        var result = [Any]()
        
        for index in 0...parts.count - 1 {
            let part = parts[index]
            let value = values[index]
            guard let formatSpecifier = part.formatSpecifier else {
                result.append(value)
                continue
            }
            switch formatSpecifier {
            case .object: result.append(value)
            case .double: result.append(Double(value)!)
            case .int: result.append(Int(value)!)
            case .uInt: result.append(UInt(value)!)
            case .character: result.append(Character(value))
            case .cStringPointer: result.append(Double(value)!)
            case .voidPointer: result.append(Double(value)!)
            case .topType: result.append(value)
            }
        }
        
        return result
	}
    
    func findKey(for plurals: [AnyHashable: Any], for text: String) -> (key: String?, values: [Any]?) {
        for (key, plural) in plurals {
            guard let plural = plural as? [AnyHashable: Any] else { continue }
            for(key1, value) in plural {
                if key1 as! String == "NSStringLocalizedFormatKey" { continue }
                guard let value = value as? [String: String] else { continue }
                for (key2, formatedString) in value {
                    guard key2 != "NSStringFormatSpecTypeKey" else { continue }
                    guard key2 != "NSStringFormatValueTypeKey" else { continue }
                    // As plurals can be simple string then check whether it is equal to text. If not do the same as for formated string.
                    if formatedString == text { return (key as? String, nil) }
                    if findMatch(for: formatedString, with: text) {
                        let values = findValues(for: text, with: formatedString)
                        return (key as? String, values)
                    }
                }
            }
        }
        return (nil, nil)
    }
}
