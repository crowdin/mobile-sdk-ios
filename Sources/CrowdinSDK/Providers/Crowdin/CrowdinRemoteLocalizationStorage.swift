//
//  CrowdinRemoteLocalizationStorage.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/27/19.
//

import Foundation

class CrowdinRemoteLocalizationStorage: RemoteLocalizationStorageProtocol {
    var localization: String
    var organizationName: String?
    var localizations: [String]
    var hashString: String
    var name: String = "Crowdin"
    var manifestManager: ManifestManager

    private var crowdinDownloader: CrowdinLocalizationDownloader
    private var crowdinSupportedLanguages: CrowdinSupportedLanguages {
        manifestManager.crowdinSupportedLanguages
    }

    init(localization: String, config: CrowdinProviderConfig) {
        self.localization = localization
        self.hashString = config.hashString
        self.organizationName = config.organizationName
        self.manifestManager = ManifestManager.manifest(
            for: config.hashString,
            sourceLanguage: config.sourceLanguage,
            organizationName: config.organizationName,
            minimumManifestUpdateInterval: config.minimumManifestUpdateInterval
        )
        self.crowdinDownloader = CrowdinLocalizationDownloader(manifestManager: manifestManager)
        self.localizations = self.manifestManager.iOSLanguages
    }

    func prepare(with completion: @escaping () -> Void) {
        self.downloadCrowdinSupportedLanguages { [weak self] in
            guard let self = self else { return }
            self.downloadManifest(completion: completion)
        }
    }

    func downloadCrowdinSupportedLanguages(completion: @escaping () -> Void) {
        if !crowdinSupportedLanguages.loaded {
            crowdinSupportedLanguages.downloadSupportedLanguages(completion: {
                completion()
            }, error: {
                LocalizationUpdateObserver.shared.notifyError(with: [$0])
                completion()
            })
        } else {
            completion()
        }
    }

    func downloadManifest(completion: @escaping () -> Void) {
        self.manifestManager.download(completion: { [weak self] in
            guard let self = self else { return }
            self.localizations = self.manifestManager.iOSLanguages
            self.localization = CrowdinSDK.currentLocalization ?? Bundle.main.preferredLanguage(with: self.localizations)
            completion()
        })
    }
    required init(localization: String, sourceLanguage: String, organizationName: String?, minimumManifestUpdateInterval: TimeInterval) {
        self.localization = localization
        guard let hashString = Bundle.main.crowdinDistributionHash else {
            fatalError("Please add CrowdinDistributionHash key to your Info.plist file")
        }
        self.hashString = hashString
        self.manifestManager = ManifestManager.manifest(
            for: hashString,
            sourceLanguage: sourceLanguage,
            organizationName: organizationName,
            minimumManifestUpdateInterval: minimumManifestUpdateInterval
        )
        self.crowdinDownloader = CrowdinLocalizationDownloader(manifestManager: self.manifestManager)
        self.localizations = []
    }

    func fetchData(completion: @escaping LocalizationStorageCompletion, errorHandler: LocalizationStorageError?) {
        guard self.localizations.contains(self.localization) else {
            let error = NSError(domain: "Remote storage doesn't contains selected localization.", code: defaultCrowdinErrorCode, userInfo: nil)
            errorHandler?(error)
            LocalizationUpdateObserver.shared.notifyError(with: [error])
            return
        }
        let localization = self.localization
        self.crowdinDownloader.download(with: self.hashString, for: localization) { [weak self] strings, plurals, errors in
            guard let self = self else { return }
            completion(self.localizations, localization, strings, plurals)

            LocalizationUpdateObserver.shared.notifyDownload()

            if let errors = errors {
                LocalizationUpdateObserver.shared.notifyError(with: errors)
            }
        }
    }

    /// Remove add stored E-Tag headers for every file and cached manifest file
    func deintegrate() {
        FileEtagStorage.clear()
        manifestManager.clear()
    }
}
