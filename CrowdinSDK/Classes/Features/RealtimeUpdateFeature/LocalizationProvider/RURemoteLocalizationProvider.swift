//
//  RealtimeUpdatesLocalizationProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 08.02.2020.
//

import Foundation

class RURemoteLocalizationProvider: RemoteLocalizationStorageProtocol {
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
    
    func fetchData(completion: @escaping LocalizationStorageCompletion) {
        fileDownloader.getFiles(for: hash) { (fileIDs, error) in
            if let error = error { print(error.localizedDescription) }
            guard let fileIDs = fileIDs else {
                completion(nil, nil, nil)
                return
            }
            self.fileDownloader.download(strings: fileIDs, plurals: [], with: self.hash, for: self.localization) { (strings, plurals, errors) in
                if let errors = errors { errors.forEach({ print($0.localizedDescription) }) }
                completion([self.localization], strings, plurals)
            }
        }
    }
}
