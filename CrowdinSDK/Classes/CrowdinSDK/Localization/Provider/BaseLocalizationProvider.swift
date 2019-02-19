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
		pluralsFolder.directories.forEach({ try? $0.remove() })
        let localizationFolderName = localization + "-" + UUID().uuidString
        self.pluralsBundle = DictionaryBundle(path: pluralsFolder.path + "/" + localizationFolderName, fileName: "Localizable.stringsdict", dictionary: self.plurals)
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
        var key = localizationStrings.first(where: { $1 == text })?.key
        if key == nil {
            key = findKey(in: self.localizationStrings, for: text)
			if let key = key, let format = localizationStrings[key] {
				let values = self.findValues(for: text, with: format)
				print(values)
			}
			
		}
//        if key == nil, let plurals = self.pluralsBundle?.dictionary {
//            key = findKey(for: plurals)
//        }
        return key
    }
	
//    https://github.com/mac-cain13/R.swift/blob/master/Sources/RswiftCore/ResourceTypes/StringParam.swift
	func findKey(in strings: [String: String], for text: String) -> String? {
        for (key, value) in strings {
            let matches = formatTypesRegEx.matches(in: value, options: [], range: NSRange(location: 0, length: value.count))
            guard matches.count > 0 else { continue }
            let ranges = matches.compactMap({ $0.range })
            let nsStringValue = value as NSString
            let components = nsStringValue.splitBy(ranges: ranges)
	
            var isIncluded = true
            components.forEach { (component) in
                if !text.contains(component) {
                    isIncluded = false
                    return
                }
            }
            if isIncluded { return key }
        }
        return nil
    }
	
	public func findValues(for string: String, with format: String) -> [String] {
		let parts = FormatPart.formatParts(formatString: format)
		let matches = formatTypesRegEx.matches(in: format, options: [], range: NSRange(location: 0, length: format.count))
		guard matches.count > 0 else { return [] }
		let ranges = matches.compactMap({ $0.range })
		let nsStringValue = format as NSString
		let components = nsStringValue.splitBy(ranges: ranges)
		
		let nsStringText = string as NSString
		
		var valueRanges = [NSRange]()
		components.forEach({ valueRanges.append(nsStringText.range(of: $0)) })

		return nsStringText.splitBy(ranges: valueRanges)
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
