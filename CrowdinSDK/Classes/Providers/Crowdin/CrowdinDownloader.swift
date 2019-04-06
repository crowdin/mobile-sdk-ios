//
//  CrowdinDownloader.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/24/19.
//

import Foundation

typealias CrowdinDownloaderCompletion = (_ localizations: [String], _ strings: [String: String], _ plurals: [AnyHashable: Any], _ errors: [Error]) -> Void

protocol CrowdinDownloaderProtocol {
    func download(strings: [String], plurals: [String], with hash: String, projectIdentifier: String, projectKey: String, for localization: String, completion: @escaping CrowdinDownloaderCompletion)
}

class CrowdinDownloader: CrowdinDownloaderProtocol {
    // swiftlint:disable implicitly_unwrapped_optional
    var completion: CrowdinDownloaderCompletion!
    
    fileprivate let operationQueue = OperationQueue()
    fileprivate var strings: [String: String] = [:]
    fileprivate var plurals: [AnyHashable: Any] = [:]
    fileprivate var localizations: [String] = []
    fileprivate var errors: [Error] = []
    
    func download(strings: [String], plurals: [String], with hash: String, projectIdentifier: String, projectKey: String, for localization: String, completion: @escaping CrowdinDownloaderCompletion) {
        self.strings = [:]
        self.plurals = [:]
        self.localizations = []
        
        self.completion = completion
        let completionBlock = BlockOperation {
            self.completion(self.localizations, self.strings, self.plurals, self.errors)
            print(self.strings)
            print(self.plurals)
        }
        
        strings.forEach { (string) in
            let download = CrowdinStringsDownloadOperation(hash: hash, file: string, localization: localization)
            download.completion = { (strings, error) in
                if let error = error {
                    self.errors.append(error)
                    print(error.localizedDescription)
                }
                guard let strings = strings else { return }
                self.strings.merge(with: strings)
            }
            completionBlock.addDependency(download)
            operationQueue.addOperation(download)
        }
        
        plurals.forEach { (plural) in
            let download = CrowdinPluralsDownloadOperation(hash: hash, file: plural, localization: localization)
            download.completion = { (plurals, error) in
                if let error = error {
                    self.errors.append(error)
                    print(error.localizedDescription)
                }
                guard let plurals = plurals else { return }
                self.plurals.merge(with: plurals)
            }
            completionBlock.addDependency(download)
            operationQueue.addOperation(download)
        }
        
        let infoOperation = DownloadProjectInfoOperation(projectIdentifier: projectIdentifier, projectKey: projectKey)
        infoOperation.completion = { projectInfo, error in
            if let error = error {
                self.errors.append(error)
                print(error.localizedDescription)
            }
            guard let projectInfo = projectInfo else { return }
            self.localizations = projectInfo.languages?.compactMap({ $0.code }) ?? []
            print(self.localizations)
        }
        completionBlock.addDependency(infoOperation)
        operationQueue.addOperation(infoOperation)
        
        operationQueue.addOperation(completionBlock)
    }
    
}
