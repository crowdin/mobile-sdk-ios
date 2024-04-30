//
//  RealtimeUpdatesLocalizationProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 08.02.2020.
//

import Foundation

class RURemoteLocalizationStorage: RemoteLocalizationStorageProtocol {
    var name: String = "RURemoteLocalizationProvider"

    func deintegrate() { }
    
    var localization: String
    var localizations: [String] {
        manifestManager.iOSLanguages
    }
    let hash: String
    let fileDownloader: RUFilesDownloader
    let manifestManager: ManifestManager
    
    init(localization: String, sourceLanguage: String, hash: String, projectId: String, organizationName: String?) {
        self.localization = localization
        self.hash = hash
        manifestManager = ManifestManager.manifest(for: hash, sourceLanguage: sourceLanguage, organizationName: organizationName)
        self.fileDownloader = RUFilesDownloader(projectId: projectId, manifestManager: manifestManager, organizationName: organizationName)
    }
    
    func prepare(with completion: @escaping (() -> Void)) {
        manifestManager.download(completion: completion)
    }
    
    func fetchData(completion: @escaping LocalizationStorageCompletion, errorHandler: LocalizationStorageError?) {
        self.fileDownloader.download(with: hash, for: localization) { (strings, plurals, errors) in
            if let errors = errors { errors.forEach { errorHandler?($0) } }
            completion([self.localization], self.localization, strings, plurals)
        }
    }
}
