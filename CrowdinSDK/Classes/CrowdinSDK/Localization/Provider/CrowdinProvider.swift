//
//  CrowdinProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/2/19.
//

import Foundation

class CrowdinProvider: LocalizationProvider {
    let crowdinFolder = DocumentsFolder(name: Bundle.main.bundleId + String.dot + "Crowdin")
    var allKeys: [String] = []
    var allValues: [String] = []
    var localizationDict: [String: String] = [:]
    var localizations: [String]  {
        return crowdinFolder.files.compactMap({ $0.name })
    }
    var localization: String {
        didSet {
            self.refresh()
        }
    }
    
    required init(localization: String) {
        self.localization = localization
        self.refresh()
        self.createCrowdinFolderIfNeeded()
    }
    
    func refresh() {
        guard let sdkFile = crowdinFolder.files.filter({ $0.name == localization }).first else { return }
        guard let data = sdkFile.content else { return }
        guard let content = try? JSONDecoder().decode([String: String].self, from: data) else { return }
        self.localizationDict = content
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
    
    func deintegrate() {
        self.deleteCrowdinFolder()
    }
}
