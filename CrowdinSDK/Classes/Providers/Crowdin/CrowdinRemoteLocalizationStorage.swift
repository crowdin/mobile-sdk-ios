//
//  CrowdinRemoteLocalizationStorage.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/27/19.
//

import Foundation

public let CrowdinProviderDidDownloadLocalization = Notifications.CrowdinProviderDidDownloadLocalization.rawValue
public let CrowdinProviderDownloadError = Notifications.CrowdinProviderDownloadError.rawValue

extension Notification.Name {
    public static let CrowdinProviderDidDownloadLocalization = Notification.Name(Notifications.CrowdinProviderDidDownloadLocalization.rawValue)
    public static let CrowdinProviderDownloadError = Notification.Name(Notifications.CrowdinProviderDownloadError.rawValue)
}

class CrowdinRemoteLocalizationStorage: RemoteLocalizationStorageProtocol {
    public var localization: String
    var localizations: [String]
    var hashString: String
    var stringsFileNames: [String]
    var pluralsFileNames: [String]
    var name: String = "Crowdin"
    
    private let crowdinDownloader: CrowdinDownloaderProtocol
    
    init(hashString: String, stringsFileNames: [String], pluralsFileNames: [String], localization: String, localizations: [String]) {
        self.hashString = hashString
        self.stringsFileNames = stringsFileNames
        self.pluralsFileNames = pluralsFileNames
        self.localization = localization
        self.localizations = localizations
        self.crowdinDownloader = CrowdinLocalizationDownloader()
    }
    
    init(localization: String, config: CrowdinProviderConfig) {
        self.hashString = config.hashString
        self.stringsFileNames = config.stringsFileNames
        self.pluralsFileNames = config.pluralsFileNames
        self.localization = localization
        self.localizations = config.localizations
        self.crowdinDownloader = CrowdinLocalizationDownloader()
    }
    
    required init(localization: String) {
        self.localization = localization
        self.crowdinDownloader = CrowdinLocalizationDownloader()
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
