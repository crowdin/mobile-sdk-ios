//
//  CrowdinRemoteLocalizationStorage.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/27/19.
//

import Foundation

class CrowdinRemoteLocalizationStorage: RemoteLocalizationStorage {
    public var localization: String
    var hashString: String
    var projectIdentifier: String
    var projectKey: String
    var stringsFileNames: [String]
    var pluralsFileNames: [String]
    
    private let crowdinDownloader: CrowdinDownloaderProtocol
    
    init(hashString: String, stringsFileNames: [String], pluralsFileNames: [String], projectIdentifier: String, projectKey: String, localization: String) {
        self.hashString = hashString
        self.projectIdentifier = projectIdentifier
        self.projectKey = projectKey
        self.stringsFileNames = stringsFileNames
        self.pluralsFileNames = pluralsFileNames
        self.localization = localization
        self.crowdinDownloader = CrowdinDownloader()
    }
    
    required init(localization: String) {
        self.localization = localization
        self.crowdinDownloader = CrowdinDownloader()
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
        
    }
    
    func fetchData(completion: @escaping ([String], [String: String], [AnyHashable: Any]) -> Void) {
         let crowdinLocalization = CrowdinSupportedLanguages.shared.crowdinLanguageCode(for: localization) ?? localization
        self.crowdinDownloader.download(strings: stringsFileNames, plurals: pluralsFileNames, with: hashString, projectIdentifier: projectIdentifier, projectKey: projectKey, for: crowdinLocalization, success: { localizations, strings, plurals in
            completion(localizations, strings, plurals)
            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification(name: Notification.Name.CrowdinProviderDidDownloadLocalization))
            }
        }, error: { error in
            print(error.localizedDescription)
        })
    }
}
