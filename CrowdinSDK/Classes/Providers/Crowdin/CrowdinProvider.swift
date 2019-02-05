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
        self.localization = localization
    }
    
    let crowdinFolder = DocumentsFolder(name: Bundle.main.bundleId + String.dot + "Crowdin")
    var allKeys: [String] = []
    var allValues: [String] = []
    public var localizationDict: [String: String] = [:]
    public var localizations: [String]  {
        let localizations = crowdinFolder.files.compactMap({ $0.name })
        if localizations.isEmpty { return Bundle.main.localizations }
        return localizations
    }
    public var localization: String? {
        didSet {
            self.refresh()
        }
    }
    
    public required init(localization: String) {
        self.localization = localization
        self.refresh()
        self.createCrowdinFolderIfNeeded()
		DispatchQueue(label: "localization").async {
			Thread.sleep(forTimeInterval: 5)
			self.localizationCompleted()
		}
    }
    
    func refresh() {
        guard let sdkFile = crowdinFolder.files.filter({ $0.name == localization }).first else { return }
        guard let data = sdkFile.content else { return }
        guard let content = try? JSONDecoder().decode([String: String].self, from: data) else { return }
        self.localizationDict = content
		
		self.localizationDict.keys.forEach { (key) in
			self.localizationDict[key] = self.localizationDict[key]! + "[C]"
		}
		DispatchQueue(label: "localization").async {
			Thread.sleep(forTimeInterval: 5)
			self.localizationCompleted()
		}
    }
    
    func readAllKeysAndValues() {
        crowdinFolder.files.forEach({
            guard let data = $0.content else { return }
            guard let content = try? JSONDecoder().decode([String: String].self, from: data) else { return }
            allKeys.append(contentsOf: content.keys)
            allValues.append(contentsOf: content.values)
        })
        let uniqueKeys: Set<String> = Set<String>(allKeys)
        allKeys = ([String])(uniqueKeys)
        let uniqueValues: Set<String> = Set<String>(allValues)
        allValues = ([String])(uniqueValues)
    }
    
    func createCrowdinFolderIfNeeded() {
        let crowdinFolder = DocumentsFolder(name: Bundle.main.bundleId + String.dot + "Crowdin")
        if !crowdinFolder.isCreated { try? crowdinFolder.create() }
    }
    
    func deleteCrowdinFolder() {
        let crowdinFolder = DocumentsFolder(name: Bundle.main.bundleId + String.dot + "Crowdin")
        if crowdinFolder.isCreated { try? crowdinFolder.delete() }
    }
    
    public func deintegrate() {
        self.deleteCrowdinFolder()
    }
}
