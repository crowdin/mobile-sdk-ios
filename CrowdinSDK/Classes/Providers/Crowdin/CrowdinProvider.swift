//
//  CrowdinProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/2/19.
//

import Foundation

public class CrowdinProvider: LocalizationProvider {
    public var localizationCompleted: LocalizationProviderHandler = { }
    
    public required init() {
		self.refresh()
		self.createCrowdinFolderIfNeeded()
		DispatchQueue(label: "localization").async {
			Thread.sleep(forTimeInterval: 5)
			self.localizationCompleted()
		}
	}

    public func setLocalization(_ localization: String?) {
        if self.localization != localization {
            self.refresh()
        }
        self.localization = localization
    }
    
    var allKeys: [String] = []
    var allValues: [String] = []
    public var localizationDict: [String: String] = [:]
    public var localizations: [String]  {
        return Bundle.main.localizations
    }
    public var localization: String?
    
    public required init(localization: String) {
        self.localization = localization
        self.refresh()
        self.createCrowdinFolderIfNeeded()
		DispatchQueue(label: "localization").async {
			Thread.sleep(forTimeInterval: 5)
			self.localizationCompleted()
		}
    }
    
    public func deintegrate() { }
    
    func refresh() {
        DispatchQueue(label: "localization").async {
            Thread.sleep(forTimeInterval: 5)
            let extractor = LocalizationExtractor(localization: self.localization)
            self.localizationDict = extractor.localizationDict
            self.localizationDict.keys.forEach { (key) in
                self.localizationDict[key] = self.localizationDict[key]! + "[cw]"
            }
            self.localizationCompleted()
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
