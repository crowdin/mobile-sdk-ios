//
//  CrowdinProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/2/19.
//

import Foundation

public class CrowdinProvider: LocalizationProvider {
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
    
    var pluralsBundle: Bundle!
    var pluralsFolder: Folder? = try? DocumentsFolder.createFolder(with: "Plurals")
    var allKeys: [String] = []
    var allValues: [String] = []
    public var localizationDict: [String: String] = [:]
    public var localizationPluralsDict: NSMutableDictionary = NSMutableDictionary()
    public var localizations: [String]  {
        return Bundle.main.localizations
    }
    public var localization: String
    
    public func deintegrate() { }
    
	func refresh() {
		let extractor = LocalizationExtractor(localization: self.localization)
		self.localizationDict = extractor.localizationDict
		self.localizationDict.keys.forEach { (key) in
            self.localizationDict[key] = self.localizationDict[key]! + "[\(localization)][cw]"
		}
        self.localizationPluralsDict = extractor.localizationPluralsDict
        guard let path = pluralsFolder?.path else { return }
        self.pluralsBundle = Bundle(path: path)
        let plist = PlistFile(path: self.pluralsBundle.bundlePath + "/Localizable.stringsdict")
        plist.file = self.localizationPluralsDict
        try? plist.save()
        self.pluralsBundle.load()
	}
    
	
    func readAllKeysAndValues() {
        let extractor = LocalizationExtractor(localization: self.localization)
        let uniqueKeys: Set<String> = Set<String>(extractor.allKeys)
        allKeys = ([String])(uniqueKeys)
        let uniqueValues: Set<String> = Set<String>(extractor.allValues)
        allValues = ([String])(uniqueValues)
    }
    
    public func localizedString(for key: String) -> String? {
        let string = self.pluralsBundle.swizzled_LocalizedString(forKey: key, value: nil, table: nil)
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
