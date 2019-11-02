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
    var localization: String
    var localizations: [String]
    var hashString: String
    var stringsFileNames: [String]
    var pluralsFileNames: [String]
    var name: String = "Crowdin"
    var enterprise: Bool
    private var crowdinDownloader: CrowdinDownloaderProtocol
    
    init(localization: String, config: CrowdinProviderConfig, enterprise: Bool) {
        self.hashString = config.hashString
        self.stringsFileNames = config.stringsFileNames
        self.pluralsFileNames = config.pluralsFileNames
        self.localization = localization
        self.localizations = config.localizations
        self.crowdinDownloader = CrowdinLocalizationDownloader(enterprise: enterprise)
        self.enterprise = enterprise
    }
    
    required init(localization: String, enterprise: Bool) {
        self.localization = localization
        self.crowdinDownloader = CrowdinLocalizationDownloader(enterprise: enterprise)
        self.enterprise = enterprise
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
        self.crowdinDownloader = CrowdinLocalizationDownloader(enterprise: self.enterprise)
        self.crowdinDownloader.download(strings: stringsFileNames, plurals: pluralsFileNames, with: hashString, for: localization, completion: { [weak self] strings, plurals, errors in
            guard let self = self else { return }
            completion(self.localizations, strings, plurals)
            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification(name: Notification.Name.CrowdinProviderDidDownloadLocalization))
                
                if let errors = errors {
                    NotificationCenter.default.post(name: Notification.Name.CrowdinProviderDownloadError, object: errors)
                }
            }
        })
    }
    
    /// Remove add stored E-Tag headers for every file.
    func deintegrate() {
        for supportedLocalization in localizations {
            self.stringsFileNames.forEach({
                let filePath = CrowdinPathsParser.shared.parse($0, localization: supportedLocalization)
                UserDefaults.standard.removeObject(forKey: filePath)
            })
            self.pluralsFileNames.forEach({
                let filePath = CrowdinPathsParser.shared.parse($0, localization: supportedLocalization)
                UserDefaults.standard.removeObject(forKey: filePath)
            })
        }
        UserDefaults.standard.synchronize()
    }
}
