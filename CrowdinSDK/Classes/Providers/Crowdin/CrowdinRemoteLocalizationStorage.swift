//
//  CrowdinRemoteLocalizationStorage.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/27/19.
//

import Foundation

class CrowdinRemoteLocalizationStorage: RemoteLocalizationStorageProtocol {
    var localization: String
    var localizations: [String]
    var hashString: String
    var stringsFileNames: [String] = []
    var pluralsFileNames: [String] = []
    var name: String = "Crowdin"
    var enterprise: Bool
    private var crowdinDownloader: CrowdinLocalizationDownloader
    private var _localizations: [String]?
    
    init(localization: String, config: CrowdinProviderConfig, enterprise: Bool) {
        self.localization = localization
        self.enterprise = enterprise
        self.hashString = config.hashString
        self.crowdinDownloader = CrowdinLocalizationDownloader()
        self.localizations = ManifestManager.shared(for: hashString).iOSLanguages
    }
    
    func prepare(with completion: @escaping () -> Void) {
        if !CrowdinSupportedLanguages.shared.loaded {
            CrowdinSupportedLanguages.shared.downloadSupportedLanguages {
                self.localizations = ManifestManager.shared(for: self.hashString).iOSLanguages
                completion()
            }
        } else {
            completion()
        }
    }
    
    required init(localization: String, enterprise: Bool) {
        self.localization = localization
        self.enterprise = enterprise
        guard let hashString = Bundle.main.crowdinDistributionHash else {
            fatalError("Please add CrowdinDistributionHash key to your Info.plist file")
        }
        self.hashString = hashString
        self.crowdinDownloader = CrowdinLocalizationDownloader()
        self.localizations = ManifestManager.shared(for: hashString).iOSLanguages
    }
    
    func fetchData(completion: @escaping LocalizationStorageCompletion, errorHandler: LocalizationStorageError?) {
        self.crowdinDownloader = CrowdinLocalizationDownloader()
        self.crowdinDownloader.download(with: self.hashString, for: self.localization) { [weak self] strings, plurals, errors in
            guard let self = self else { return }
            completion(self.localizations, strings, plurals)
            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification(name: Notification.Name(Notifications.ProviderDidDownloadLocalization.rawValue)))
                
                if let errors = errors {
                    NotificationCenter.default.post(name: Notification.Name(Notifications.ProviderDownloadError.rawValue), object: errors)
                    errors.forEach({ errorHandler?($0) })
                }
            }
        }
    }
    
    /// Remove add stored E-Tag headers for every file.
    func deintegrate() {
        ETagStorage.shared.clear()
    }
}
