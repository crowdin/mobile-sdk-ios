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
    public init(hashString: String, stringsFileNames: [String], pluralsFileNames: [String], projectIdentifier: String, projectKey: String) {
        let localization = Bundle.main.preferredLanguage
        super.init(localization: localization, localStorage: CrowdinLocalLocalizationStorage(localization: localization), remoteStorage: CrowdinRemoteLocalizationStorage(hashString: hashString, stringsFileNames: stringsFileNames, pluralsFileNames: pluralsFileNames, projectIdentifier: projectIdentifier, projectKey: projectKey, localization: localization))
    }
    
    public init() {
        let localization = Bundle.main.preferredLanguage
        super.init(localization: localization, localStorage: CrowdinLocalLocalizationStorage(localization: localization), remoteStorage: CrowdinRemoteLocalizationStorage(localization: localization))
    }
    
    public required init(localization: String, localStorage: LocalLocalizationStorage, remoteStorage: RemoteLocalizationStorage) {
        super.init(localization: localization, localStorage: localStorage, remoteStorage: remoteStorage)
    }
}
