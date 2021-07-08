//
//  FirebaseLocalLocalizationStorage.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/27/19.
//

import Foundation

class FirebaseLocalLocalizationStorage: LocalLocalizationStorage {
    let crowdinFolder: FolderProtocol = CrowdinFolder.shared
    let firebaseFolder: FolderProtocol
    
//    var localizations: [String] = []
    
    override var strings: [String: String] {
        didSet {
            self.save()
        }
    }
    
    override var plurals: [AnyHashable: Any] {
        didSet {
            self.save()
        }
    }
    
    override var localization: String {
        didSet {
            refresh()
        }
    }
    
    func fetchData(completion: @escaping LocalizationStorageCompletion) {
        self.refresh()
//        completion([], strings, plurals)
    }
    
    required override init(localization: String) {
        // swiftlint:disable force_try
        self.firebaseFolder = try! crowdinFolder.createFolder(with: "Firebase")
        
        super.init(localization: localization)
        
        self.localization = localization
    }
    
    func refresh() {
        guard let lolcaizationFile = firebaseFolder.files.filter({ $0.name == localization }).first else { return }
        guard let dictionary = NSDictionary(contentsOfFile: lolcaizationFile.path)  else { return }
        if let strings = dictionary[Keys.strings.rawValue] as? [String: String] {
            self.strings = strings
        }
        if let plurals = dictionary[Keys.plurals.rawValue] as? [AnyHashable: Any] {
            self.plurals = plurals
        }
    }
    
    override func save() {
        let localizationDict = [Keys.strings.rawValue : strings, Keys.plurals.rawValue : plurals]
        let path = self.firebaseFolder.path + String.pathDelimiter + localization + FileType.plist.extension
        let stringsFile = DictionaryFile(path: path)
        stringsFile.file = localizationDict
        try? stringsFile.save()
    }
    
    func removeFolders() {
        if crowdinFolder.isCreated { try? crowdinFolder.remove() }
        if firebaseFolder.isCreated { try? firebaseFolder.remove() }
    }
}
