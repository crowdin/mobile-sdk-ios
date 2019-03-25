//
//  CrowdinProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/2/19.
//

import Foundation

extension Notification.Name {
    public static let CrowdinProviderDidDownloadLocalization = Notification.Name("CrowdinProviderDidDownloadLocalization")
}

public class CrowdinProvider: BaseLocalizationProvider {
    let localizationFolder: FolderProtocol = try! CrowdinFolder.shared.createFolder(with: Strings.Crowdin.rawValue)
    
    var hashString: String
    var projectIdentifier: String
    var projectKey: String
    var stringsFileNames: [String]
    var pluralsFileNames: [String]
    let crowdinDownloader: CrowdinDownloaderProtocol
    
    fileprivate let downloadOperationQueue = OperationQueue()
    
    public init(hashString: String, stringsFileNames: [String], pluralsFileNames: [String], projectIdentifier: String, projectKey: String) {
        self.hashString = hashString
        self.projectIdentifier = projectIdentifier
        self.projectKey = projectKey
        self.stringsFileNames = stringsFileNames
        self.pluralsFileNames = pluralsFileNames
        self.crowdinDownloader = CrowdinDownloader()
        super.init()
        self.loadSavedLocalization()
        self.downloadLocalization()
    }
    
    public override init() {
        guard let hashString = Bundle.main.crowdinHash else {
            fatalError("Please add CrowdinHash key to your Info.plist file")
        }
        self.hashString = hashString
        guard let projectIdentifier = Bundle.main.projectIdentifier else {
            fatalError("Please add CrowdinProjectIdentifier key to your Info.plist file")
        }
        self.projectIdentifier = projectIdentifier
        guard let projectKey = Bundle.main.projectKey else {
            fatalError("Please add CrowdinProjectKey key to your Info.plist file")
        }
        self.projectKey = projectKey
        guard let crowdinStringsFileNames = Bundle.main.crowdinStringsFileNames else {
            fatalError("Please add CrowdinStringsFileNames key to your Info.plist file")
        }
        self.stringsFileNames = crowdinStringsFileNames
        guard let crowdinPluralsFileNames = Bundle.main.crowdinPluralsFileNames else {
            fatalError("Please add CrowdinPluralsFileNames key to your Info.plist file")
        }
        self.pluralsFileNames = crowdinPluralsFileNames
        self.crowdinDownloader = CrowdinDownloader()
        super.init()
        self.loadSavedLocalization()
        self.downloadLocalization()
    }
    
    public required init(localizations: [String], strings: [String : String], plurals: [AnyHashable : Any]) {
        fatalError("init(localizations:strings:plurals:) has not been implemented")
    }
    
    func downloadLocalization() {
        self.crowdinDownloader.download(strings: self.stringsFileNames, plurals: self.pluralsFileNames, with: self.hashString, projectIdentifier: self.projectIdentifier, projectKey: self.projectKey, for: self.localization, success: { (strings, plurals, localizations) in
            self.strings = strings
            self.plurals = plurals
            self.localizations = localizations
            self.saveLocalization()
            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification(name: Notification.Name.CrowdinProviderDidDownloadLocalization))
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func saveLocalization() {
        let localizationFilePath = self.localizationFolder.path + String.pathDelimiter + localization + FileType.plist.extension
        let localizationFile = DictionaryFile(path: localizationFilePath)
        localizationFile.file = [Keys.strings.rawValue : strings, Keys.plurals.rawValue: plurals]
        try? localizationFile.save()
        
        let localizationsFilePath = self.localizationFolder.path + String.pathDelimiter + "localizations" + FileType.plist.extension
        let localizationsFile = DictionaryFile(path: localizationsFilePath)
        localizationsFile.file = [Keys.localizations.rawValue : localizations]
        try? localizationsFile.save()
    }
    
    func loadSavedLocalization() {
        let localizationFilePath = self.localizationFolder.path + String.pathDelimiter + localization + FileType.plist.extension
        let localizationFile = DictionaryFile(path: localizationFilePath)
        if let strings = localizationFile.file?[Keys.strings.rawValue] as? [String : String] {
            self.strings = strings
            self.setupLocalizationStrings()
        }
        if let plurals = localizationFile.file?[Keys.plurals.rawValue] as? [AnyHashable : Any] {
            self.plurals = plurals
            self.setupPluralsBundle()
        }
        
        let localizationsFilePath = self.localizationFolder.path + String.pathDelimiter + "localizations" + FileType.plist.extension
        let localizationsFile = DictionaryFile(path: localizationsFilePath)
        if let localizations = localizationsFile.file?[Keys.localizations.rawValue] as? [String] {
            self.localizations = localizations
        }
    }
    
    public override func set(localization: String?) {
        super.set(localization: localization)
        self.loadSavedLocalization()
        self.downloadLocalization()
    }
}
