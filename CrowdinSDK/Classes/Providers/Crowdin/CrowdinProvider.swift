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
    
    var allKeys: [String] = []
    var allValues: [String] = []
    public var localizationDict: [String: String] = [:]
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
	}
	
    func readAllKeysAndValues() {
        let extractor = LocalizationExtractor(localization: self.localization)
        let uniqueKeys: Set<String> = Set<String>(extractor.allKeys)
        allKeys = ([String])(uniqueKeys)
        let uniqueValues: Set<String> = Set<String>(extractor.allValues)
        allValues = ([String])(uniqueValues)
    }
}
