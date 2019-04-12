//
//  CrowdinDownloader.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/24/19.
//

import Foundation

typealias CrowdinDownloaderCompletion = (_ strings: [String: String]?, _ plurals: [AnyHashable: Any]?, _ errors: [Error]?) -> Void

protocol CrowdinDownloaderProtocol {
    func download(strings: [String], plurals: [String], with hash: String, for localization: String, completion: @escaping CrowdinDownloaderCompletion)
}

class CrowdinDownloader: CrowdinDownloaderProtocol {
    // swiftlint:disable implicitly_unwrapped_optional
    var completion: CrowdinDownloaderCompletion!
    
    fileprivate let operationQueue = OperationQueue()
    fileprivate var strings: [String: String]? = nil
    fileprivate var plurals: [AnyHashable: Any]? = nil
    fileprivate var errors: [Error]? = nil
    
    func download(strings: [String], plurals: [String], with hash: String, for localization: String, completion: @escaping CrowdinDownloaderCompletion) {
        self.completion = completion
        let completionBlock = BlockOperation {
            self.completion(self.strings, self.plurals, self.errors)
        }
        
        strings.forEach { (string) in
            let download = CrowdinStringsDownloadOperation(hash: hash, filePath: string)
            download.completion = { (strings, error) in
                if let error = error {
                    if self.errors != nil {
                        self.errors?.append(error)
                    } else {
                        self.errors = [error]
                    }
                }
                guard let strings = strings else { return }
                if self.strings != nil {
                    self.strings?.merge(with: strings)
                } else {
                    self.strings = strings
                }
            }
            completionBlock.addDependency(download)
            operationQueue.addOperation(download)
        }
        
        plurals.forEach { (plural) in
            let download = CrowdinPluralsDownloadOperation(hash: hash, filePath: plural)
            download.completion = { (plurals, error) in
                if let error = error {
                    if self.errors != nil {
                        self.errors?.append(error)
                    } else {
                        self.errors = [error]
                    }
                }
                guard let plurals = plurals else { return }
                if self.plurals != nil {
                    self.plurals?.merge(with: plurals)
                } else {
                    self.plurals = plurals
                }
            }
            completionBlock.addDependency(download)
            operationQueue.addOperation(download)
        }
        /*
        let infoOperation = DownloadProjectInfoOperation(projectIdentifier: projectIdentifier, projectKey: projectKey)
        infoOperation.completion = { projectInfo, error in
            if let error = error {
                self.errors.append(error)
            }
            guard let projectInfo = projectInfo else { return }
            self.localizations = projectInfo.languages?.compactMap({ $0.code }) ?? []
            print(self.localizations)
        }
        completionBlock.addDependency(infoOperation)
        operationQueue.addOperation(infoOperation)
        */
        operationQueue.addOperation(completionBlock)
    }
    
}
