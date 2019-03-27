//
//  CrowdinDownloader.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/24/19.
//

import Foundation

typealias CrowdinDownloaderSuccess = (_ localizations: [String], _ strings: [String : String], _ plurals: [AnyHashable : Any]) -> Void
typealias CrowdinDownloaderError = (_ error: Error) -> Void

protocol CrowdinDownloaderProtocol {
    func download(strings: [String], plurals: [String], with hash: String, projectIdentifier: String, projectKey: String, for localization: String, success: @escaping CrowdinDownloaderSuccess, error: @escaping CrowdinDownloaderError)
}

class CrowdinDownloader: CrowdinDownloaderProtocol {
    var success: CrowdinDownloaderSuccess!
    var error: CrowdinDownloaderError!
    
    fileprivate let operationQueue = OperationQueue()
    fileprivate var strings: [String : String] = [:]
    fileprivate var plurals: [AnyHashable : Any] = [:]
    fileprivate var localizations: [String] = []
    
    func download(strings: [String], plurals: [String], with hash: String, projectIdentifier: String, projectKey: String, for localization: String, success: @escaping ([String], [String : String], [AnyHashable : Any]) -> Void, error: @escaping (Error) -> Void) {
        self.strings = [:]
        self.plurals = [:]
        self.localizations = []
        
        self.success = success
        self.error = error
        let completion = BlockOperation {
            self.success(self.localizations, self.strings, self.plurals)
        }
        
        strings.forEach { (string) in
            let download = CrowdinStringsDownloadOperation(hash: hash, file: string, localization: localization)
            download.completion = { (strings, error) in
                if let error = error {
                    self.error?(error)
                    print(error.localizedDescription)
                }
                guard let strings = strings else { return }
                self.strings.merge(with: strings)
            }
            completion.addDependency(download)
            operationQueue.addOperation(download)
        }
        
        plurals.forEach { (plural) in
            let download = CrowdinPluralsDownloadOperation(hash: hash, file: plural, localization: localization)
            download.completion = { (plurals, error) in
                if let error = error {
                    self.error?(error)
                    print(error.localizedDescription)
                }
                guard let plurals = plurals else { return }
                self.plurals.merge(with: plurals)
            }
            completion.addDependency(download)
            operationQueue.addOperation(download)
        }
        
        let infoOperation = DownloadProjectInfoOperation(projectIdentifier: projectIdentifier, projectKey: projectKey)
        infoOperation.completion = { projectInfo, error in
            if let error = error {
                self.error?(error)
                print(error.localizedDescription)
            }
            guard let projectInfo = projectInfo else { return }
            self.localizations = projectInfo.languages?.compactMap({ $0.code }) ?? []
            print(self.localizations)
        }
        completion.addDependency(infoOperation)
        operationQueue.addOperation(infoOperation)
        
        operationQueue.addOperation(completion)
    }
    
}
