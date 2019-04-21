//
//  CrowdinLocalizationProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/2/19.
//

import Foundation

public let CrowdinProviderDidDownloadLocalization = Notifications.CrowdinProviderDidDownloadLocalization.rawValue
public let CrowdinProviderDownloadError = Notifications.CrowdinProviderDownloadError.rawValue

extension Notification.Name {
    public static let CrowdinProviderDidDownloadLocalization = Notification.Name(Notifications.CrowdinProviderDidDownloadLocalization.rawValue)
    public static let CrowdinProviderDownloadError = Notification.Name(Notifications.CrowdinProviderDownloadError.rawValue)
}

public class CrowdinLocalizationProvider: BaseLocalizationProvider {    
    public init(config: CrowdinProviderConfig) {
        let localization = Bundle.main.preferredLanguage
        let localStorage = CrowdinLocalLocalizationStorage(localization: localization, localizations: config.localizations)
        let remoteStorage = CrowdinRemoteLocalizationStorage(hashString: config.hashString, stringsFileNames: config.stringsFileNames, pluralsFileNames: config.pluralsFileNames, localization: localization, localizations: config.localizations)
        super.init(localization: localization, localStorage: localStorage, remoteStorage: remoteStorage)
    }
    
    public init() {
        let localization = Bundle.main.preferredLanguage
        let localStorage = CrowdinLocalLocalizationStorage(localization: localization, localizations: [])
        let remoteStorage = CrowdinRemoteLocalizationStorage(localization: localization)
        super.init(localization: localization, localStorage: localStorage, remoteStorage: remoteStorage)
    }
    
    public required init(localization: String, localStorage: LocalLocalizationStorage, remoteStorage: RemoteLocalizationStorage) {
        super.init(localization: localization, localStorage: localStorage, remoteStorage: remoteStorage)
    }
}
