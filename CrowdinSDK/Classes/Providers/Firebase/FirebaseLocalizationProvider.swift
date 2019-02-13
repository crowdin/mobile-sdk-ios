//
//  FirebaseProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/2/19.
//

import Foundation
import FirebaseDatabase

public class FirebaseLocalizationProvider: BaseLocalizationProvider {
    let crowdinFolder = DocumentsFolder(name: Bundle.main.bundleId + ".Crowdin")
    let database: DatabaseReference = Database.database().reference()
    var allKeys: [String] = []
    var allValues: [String] = []
    
    public var path: String
    
    public required override init() {
        self.path = "localization"
        super.init()
        self.subscribe()
        self.createCrowdinFolderIfNeeded()
    }
    
    public init(path: String) {
        self.path = path
        super.init()
        self.subscribe()
        self.createCrowdinFolderIfNeeded()
    }
    
    public required init(localizations: [String], strings: [String : String], plurals: [AnyHashable : Any]) {
        self.path = "localization"
        super.init(localizations: localizations, strings: strings, plurals: plurals)
        self.subscribe()
        self.createCrowdinFolderIfNeeded()
    }
    
    public override func set(localization: String?) {
        super.set(localization: localization)
        self.refresh()
    }
    
    func refresh() {
        guard let sdkFile = crowdinFolder.files.filter({ $0.name == localization }).first else { return }
        guard let dictionary = NSDictionary(contentsOfFile: sdkFile.path)  else { return }
        if let strings = dictionary["strings"] as? [AnyHashable: Any] {
            self.set(strings: [self.localization : strings])
        }
        if let plurals = dictionary["plurals"] as? [AnyHashable: Any] {
            self.set(plurals: plurals)
        }
    }
    
    func createCrowdinFolderIfNeeded() {
        if !crowdinFolder.isCreated { try? crowdinFolder.create() }
    }
    
    func deleteCrowdinFolder() {
        if crowdinFolder.isCreated { try? crowdinFolder.delete() }
    }
    
    public override func deintegrate() {
        self.deleteCrowdinFolder()
    }
    
    func subscribe() {
        let reference = self.database.child(path)
        reference.observe(DataEventType.value) { (snapshot: DataSnapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                dictionary.keys.forEach({ (key) in
                    let strings = dictionary[key] as! [String: Any]
                    let stringsFile = DictionaryFile(path: self.crowdinFolder.path + "/" + key + ".plist")
                    stringsFile.file = strings
                    try? stringsFile.save()
                })
                self.refresh()
                CrowdinSDK.reloadUI()
            }
        }
    }
}
