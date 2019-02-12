//
//  CrowdinProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/2/19.
//

import Foundation

public class CrowdinProvider: LocalizationProvider {
    public var localizationDict: [String: String] = [:]
    public var localizations: [String]  {
        return Bundle.main.localizations
    }
    public var localization: String
    var stringsdict: DictionaryBundle?
    
    public required init(localization: String?) {
        self.localization = localization ?? Bundle.main.preferredLanguages.first ?? "en"
        self.refresh()
    }
    
    public required init() {
        self.localization = Bundle.main.preferredLanguages.first ?? "en"
		self.refresh()
	}

    public func set(localization: String?) {
        if self.localization != localization {
			self.localization = localization ?? Bundle.main.preferredLanguages.first ?? "en"
            self.refresh()
        }
    }
    
    public func deintegrate() { }
    
	func refresh() {
		let extractor = LocalizationExtractor(localization: self.localization)
		self.localizationDict = extractor.localizationDict
        self.stringsdict = DictionaryBundle(name: "Plurals", fileName: "Localizable.stringsdict", stringsDictionary: extractor.localizationPluralsDict)
	}
    
    public func localizedString(for key: String) -> String? {
        let string = self.stringsdict?.bundle.swizzled_LocalizedString(forKey: key, value: nil, table: nil)
        if string != key {
            return string
        }
        return self.localizationDict[key]
    }
    
    public func keyForString(_ text: String) -> String? {
        let key = localizationDict.first(where: { $1 == text })?.key
        return key
    }
}
