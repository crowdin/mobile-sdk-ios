//
//  CrowdinProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/2/19.
//

import Foundation

public class CrowdinProvider: BaseLocalizationProvider {
    let localizationFolder: FolderProtocol = try! CrowdinFolder.shared.createFolder(with: "Crowdin")
    
    var hashString: String
    var stringsFileNames: [String]
    var pluralsFileNames: [String]
    let crowdinAPI: CrowdinAPIProtolol
    
    fileprivate let downloadOperationQueue = OperationQueue()
    
    public init(hashString: String, stringsFileNames: [String], pluralsFileNames: [String]) {
        self.hashString = hashString
        self.stringsFileNames = stringsFileNames
        self.pluralsFileNames = pluralsFileNames
        self.crowdinAPI = CrowdinAPI(hash: hashString)
        super.init()
        self.loadSavedLocalization()
        self.downloadLocalization()
    }
    
    public override init() {
        guard let hashString = Bundle.main.crowdinHash else {
            fatalError("Please add CrowdinHash key to your Info.plist file")
        }
        self.hashString = hashString
        guard let crowdinStringsFileNames = Bundle.main.crowdinStringsFileNames else {
            fatalError("Please add CrowdinStringsFileNames key to your Info.plist file")
        }
        self.stringsFileNames = crowdinStringsFileNames
        guard let crowdinPluralsFileNames = Bundle.main.crowdinPluralsFileNames else {
            fatalError("Please add CrowdinPluralsFileNames key to your Info.plist file")
        }
        self.pluralsFileNames = crowdinPluralsFileNames
        
        self.crowdinAPI = CrowdinAPI(hash: hashString)
        super.init()
        self.loadSavedLocalization()
        self.downloadLocalization()
    }
    
    public required init(localizations: [String], strings: [String : String], plurals: [AnyHashable : Any]) {
        fatalError("init(localizations:strings:plurals:) has not been implemented")
    }
    
    func downloadLocalization() {
        self.stringsFileNames.forEach { (fileName) in
            let blockOperation = BlockAsyncOperation(block: {
                self.crowdinAPI.getStrings(file: fileName, for: self.localization, completion: { (strings, error) in
                    guard let strings = strings else { return }
                    self.strings += strings
                    self.set(strings: self.strings)
                    self.saveLocalization()
                })
            })
            downloadOperationQueue.addOperation(blockOperation)
        }
        self.pluralsFileNames.forEach { (fileName) in
            let blockOperation = BlockAsyncOperation(block: {
                self.crowdinAPI.getPlurals(file: fileName, for: self.localization, completion: { (plurals, error) in
                    guard let plurals = plurals else { return }
                    self.plurals += plurals
                    self.set(plurals: self.plurals)
                    self.saveLocalization()
                })
            })
            downloadOperationQueue.addOperation(blockOperation)
        }
    }
    
    func saveLocalization() {
        let path = self.localizationFolder.path + String.pathDelimiter + localization + FileType.plist.extension
        let localizationFile = DictionaryFile(path: path)
        localizationFile.file = ["strings": strings, "plurals": plurals]
        try? localizationFile.save()
    }
    
    func loadSavedLocalization() {
        let path = self.localizationFolder.path + String.pathDelimiter + localization + FileType.plist.extension
        let localizationFile = DictionaryFile(path: path)
        if let strings = localizationFile.file?["strings"] as? [String : String] {
            self.strings = strings
            self.setupLocalizationStrings()
        }
        if let plurals = localizationFile.file?["plurals"] as? [AnyHashable : Any] {
            self.plurals = plurals
            self.setupPluralsBundle()
        }
    }
}
