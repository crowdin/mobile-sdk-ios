//
//  CrowdinMappingDownloader.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/30/19.
//

import Foundation

class CrowdinMappingDownloader: CrowdinDownloaderProtocol {
    fileprivate var completion: CrowdinDownloaderCompletion? = nil
    
    fileprivate let operationQueue = OperationQueue()
    fileprivate var strings: [String: String]? = nil
    fileprivate var plurals: [AnyHashable: Any]? = nil
    fileprivate var errors: [Error]? = nil
    //swiftlint:disable implicitly_unwrapped_optional
    fileprivate var contentDeliveryAPI: CrowdinContentDeliveryAPI!
    
    func download(strings: [String], plurals: [String], with hash: String, for localization: String, completion: @escaping CrowdinDownloaderCompletion) {
        self.contentDeliveryAPI = CrowdinContentDeliveryAPI(hash: hash, session: URLSession.init(configuration: .ephemeral))
        
        self.strings = nil
        self.plurals = nil
        self.errors = nil
        
        self.completion = completion
        let completionBlock = BlockOperation {
            self.completion?(self.strings, self.plurals, self.errors)
        }
        
        strings.forEach { (string) in
            let download = CrowdinStringsMappingDownloadOperation(hash: hash, filePath: string, sourceLanguage: localization, contentDeliveryAPI: contentDeliveryAPI, completion: { (strings, error) in
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
            })
            completionBlock.addDependency(download)
            operationQueue.addOperation(download)
        }
        
        plurals.forEach { (plural) in
            let download = CrowdinPluralsMappingDownloadOperation(hash: hash, filePath: plural, sourceLanguage: localization, contentDeliveryAPI: contentDeliveryAPI, completion: { (plurals, error) in
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
            })
            completionBlock.addDependency(download)
            operationQueue.addOperation(download)
        }
        operationQueue.addOperation(completionBlock)
    }
    
    func getFiles(for hash: String, completion: @escaping ([String]?, Error?) -> Void) {
        self.contentDeliveryAPI = CrowdinContentDeliveryAPI(hash: hash, session: URLSession.init(configuration: .ephemeral))
        self.contentDeliveryAPI.getFiles(completion: completion)
    }
}
