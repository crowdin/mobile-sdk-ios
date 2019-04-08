//
//  CrowdinLocalizationProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/2/19.
//

import Foundation

public let CrowdinProviderDidDownloadLocalization = Notifications.CrowdinProviderDidDownloadLocalization.rawValue

extension Notification.Name {
    public static let CrowdinProviderDidDownloadLocalization = Notification.Name(Notifications.CrowdinProviderDidDownloadLocalization.rawValue)
}

public class CrowdinLocalizationProvider: BaseLocalizationProvider {    
    public init(hashString: String, stringsFileNames: [String], pluralsFileNames: [String], localizations: [String]) {
        let localization = Bundle.main.preferredLanguage
        let localStorage = CrowdinLocalLocalizationStorage(localization: localization, localizations: localizations)
        let remoteStorage = CrowdinRemoteLocalizationStorage(hashString: hashString, stringsFileNames: stringsFileNames, pluralsFileNames: pluralsFileNames, localization: localization, localizations: localizations)
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
