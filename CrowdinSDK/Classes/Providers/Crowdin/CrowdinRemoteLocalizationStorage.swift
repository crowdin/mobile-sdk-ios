//
//  CrowdinRemoteLocalizationStorage.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/27/19.
//

import Foundation

class CrowdinRemoteLocalizationStorage: RemoteLocalizationStorage {
    public var localization: String
    var localizations: [String]
    var hashString: String
    var stringsFileNames: [String]
    var pluralsFileNames: [String]
    
    private let crowdinDownloader: CrowdinDownloaderProtocol
    
    init(hashString: String, stringsFileNames: [String], pluralsFileNames: [String], localization: String, localizations: [String]) {
        self.hashString = hashString
        self.stringsFileNames = stringsFileNames
        self.pluralsFileNames = pluralsFileNames
        self.localization = localization
        self.localizations = localizations
        self.crowdinDownloader = CrowdinDownloader()
    }
    
    required init(localization: String) {
        self.localization = localization
        self.crowdinDownloader = CrowdinDownloader()
        guard let hashString = Bundle.main.crowdinHash else {
            fatalError("Please add CrowdinHash key to your Info.plist file")
        }
        self.hashString = hashString
        guard let localizations = Bundle.main.cw_localizations else {
            fatalError("Please add CrowdinLocalizations key to your Info.plist file")
        }
        self.localizations = localizations
        guard let crowdinStringsFileNames = Bundle.main.crowdinStringsFileNames else {
            fatalError("Please add CrowdinStringsFileNames key to your Info.plist file")
        }
        self.stringsFileNames = crowdinStringsFileNames
        guard let crowdinPluralsFileNames = Bundle.main.crowdinPluralsFileNames else {
            fatalError("Please add CrowdinPluralsFileNames key to your Info.plist file")
        }
        self.pluralsFileNames = crowdinPluralsFileNames
    }
    
    func fetchData(completion: @escaping LocalizationStorageCompletion) {
        let crowdinLocalization = CrowdinSupportedLanguages.shared.crowdinLanguageCode(for: localization) ?? localization
        self.crowdinDownloader.download(strings: stringsFileNames, plurals: pluralsFileNames, with: hashString, for: crowdinLocalization, completion: { strings, plurals, errors in
            completion(self.localizations, strings, plurals)
            
            // TODO: add comments here:
            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification(name: Notification.Name.CrowdinProviderDidDownloadLocalization))
                
                if let errors = errors {
                    print("Error - \(errors)")
                    NotificationCenter.default.post(name: Notification.Name.CrowdinProviderDownloadError, object: errors)
                }
            }
        })
    }
}
