//
//  FirebaseProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/2/19.
//

import Foundation
import FirebaseDatabase

public class FirebaseLocalizationProvider: LocalizationProvider {
    public var localizationCompleted: LocalizationProviderHandler = { }
    
    public required init() {
        self.subscribe()
    }
    
    public func setLocalization(_ localization: String?) {
        self.localization = localization
    }
    
    let crowdinFolder = DocumentsFolder(name: Bundle.main.bundleId + ".Crowdin")
    let database: DatabaseReference = Database.database().reference()
    var allKeys: [String] = []
    var allValues: [String] = []
    public var localizations: [String]  {
        return crowdinFolder.files.compactMap({ $0.name })
    }
    public var localizationDict: [String : String] = [:]
    
    public var localization: String? {
        didSet {
            self.refresh()
        }
    }
    public var path: String?
    
    public init(path: String) {
        self.path = path
        self.subscribe()
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
        let crowdinFolder = DocumentsFolder(name: Bundle.main.bundleId + ".Crowdin")
        if !crowdinFolder.isCreated { try? crowdinFolder.create() }
    }
    
    func deleteCrowdinFolder() {
        let crowdinFolder = DocumentsFolder(name: Bundle.main.bundleId + ".Crowdin")
        if crowdinFolder.isCreated { try? crowdinFolder.delete() }
    }
    
    public func deintegrate() {
        self.deleteCrowdinFolder()
    }
    
    func subscribe() {
        var reference = self.database
        if let url = path {
            reference = self.database.child(url)
        }
        reference.observe(DataEventType.value) { (snapshot: DataSnapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                dictionary.keys.forEach({ (key) in
                    let translation = dictionary[key] as! [String: String]
                    let data = try! JSONEncoder().encode(translation)
                    try! data.write(to: URL(fileURLWithPath: self.crowdinFolder.path + "/\(key).json"))
                })
                self.refresh()
                self.localizationCompleted()
            }
        }
    }
}
