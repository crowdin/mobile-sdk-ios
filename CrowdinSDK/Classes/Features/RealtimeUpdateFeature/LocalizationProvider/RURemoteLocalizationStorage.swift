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
    var hash: String
    var fileDownloader: RUFilesDownloader
    
    init(localization: String, hash: String, projectId: String, organizationName: String?) {
        self.localization = localization
        self.hash = hash
        self.fileDownloader = RUFilesDownloader(projectId: projectId, organizationName: organizationName)
    }
    
    func fetchData(completion: @escaping LocalizationStorageCompletion, errorHandler: LocalizationStorageError?) {
        fileDownloader.getFiles(for: hash) { (fileIDs, error) in
            if let error = error { errorHandler?(error) }
            guard let fileIDs = fileIDs else { return }
            self.fileDownloader.download(strings: fileIDs, plurals: [], with: self.hash, for: self.localization) { (strings, plurals, errors) in
                if let errors = errors { errors.forEach({ errorHandler?($0) }) }
                completion([self.localization], strings, plurals)
            }
        }
    }
}
