//
//  RUFilesDownloader.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 09.02.2020.
//

import Foundation

class RUFilesDownloader: CrowdinDownloaderProtocol {
    // swiftlint:disable implicitly_unwrapped_optional
    var completion: CrowdinDownloaderCompletion!

    fileprivate let operationQueue = OperationQueue()
    fileprivate var strings: [String: String]? = nil
    fileprivate var plurals: [AnyHashable: Any]? = nil
    fileprivate var errors: [Error]? = nil
    
    // swiftlint:disable implicitly_unwrapped_optional
    var contentDeliveryAPI: CrowdinContentDeliveryAPI!
    let projectsAPI: ProjectsAPI
    let projectId: String
    let enterprise: Bool
    
    init(projectId: String, organizationName: String? = nil) {
        self.projectId = projectId
        self.enterprise = organizationName != nil
        self.projectsAPI = ProjectsAPI(organizationName: organizationName, auth: LoginFeature.shared)
    }
    
    func download(strings: [String], plurals: [String], with hash: String, for localization: String, completion: @escaping CrowdinDownloaderCompletion) {
        self.strings = nil
        self.plurals = nil
        self.errors = nil
        
        self.completion = completion
        let completionBlock = BlockOperation { [weak self] in
            guard let self = self else { return }
            self.completion(self.strings, self.plurals, self.errors)
        }
        
        var allIDs = [String]()
        allIDs.append(contentsOf: strings)
        allIDs.append(contentsOf: plurals)
        
        allIDs.forEach { (fileId) in
            let targetLanguageId = CrowdinSupportedLanguages.shared.crowdinLanguageCode(for: localization) ?? localization
            let download = FileDataDownloadOperation(fileId: fileId, projectId: projectId, targetLanguageId: targetLanguageId, projectsAPI: projectsAPI) { [weak self] (data, error) in
                guard let self = self else {
                    return
                }
                if let error = error {
                    if self.errors != nil {
                        self.errors?.append(error)
                    } else {
                        self.errors = [error]
                    }
                }
                guard let data = data else { return }
                guard let dict = CrowdinContentDelivery.parse(data: data) else { return }
                if let strings = dict as? [String: String] {
                    if self.strings != nil {
                        self.strings?.merge(with: strings)
                    } else {
                        self.strings = strings
                    }
                } else {
                    if self.plurals != nil {
                        self.plurals?.merge(with: dict)
                    } else {
                        self.plurals = dict
                    }
                }
            }
            completionBlock.addDependency(download)
            operationQueue.addOperation(download)
        }
        
        operationQueue.addOperation(completionBlock)
    }
    
    func getFiles(for hash: String, completion: @escaping ([String]?, Error?) -> Void) {
        self.contentDeliveryAPI = CrowdinContentDeliveryAPI(hash: hash, enterprise: enterprise, session: URLSession.init(configuration: .ephemeral))
        self.contentDeliveryAPI.getFiles { (files, error) in
            guard let files = files else { completion(nil, error); return; }
            let fileNames = files.compactMap({ $0.split(separator: "/").last }).map({ String($0) })
            self.projectsAPI.getFilesList(projectId: self.projectId) { (response, error) in
                guard let response = response else { completion(nil, error); return; }
                var results = [String]()
                for file in response.data {
                    if fileNames.contains(file.data.name) {
                        results.append(String(file.data.id))
                    }
                }
                completion(results, nil)
            }
        }
    }
}
