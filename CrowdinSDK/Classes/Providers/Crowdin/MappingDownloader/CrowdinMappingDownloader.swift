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
    
    func download(with hash: String, for localization: String, completion: @escaping CrowdinDownloaderCompletion) {
        self.completion = completion
        self.getFiles(for: hash) { [weak self] (files, _, error)  in
            guard let self = self else { return }
            if let files = files {
                let strings = files.filter({ $0.isStrings })
                let plurals = files.filter({ $0.isStringsDict })
                let xliffs = files.filter({ $0.isXliff })
                self.download(strings: strings, plurals: plurals, xliffs: xliffs, with: hash, for: localization)
            }  else if let error = error {
                self.errors = [error]
                self.completion?(nil, nil, self.errors)
            }
        }
    }
    
    func download(strings: [String], plurals: [String], xliffs: [String], with hash: String, for localization: String) {
        self.contentDeliveryAPI = CrowdinContentDeliveryAPI(hash: hash, session: URLSession.init(configuration: .ephemeral))
        
        self.strings = nil
        self.plurals = nil
        self.errors = nil
        
        let completionBlock = BlockOperation {
            self.completion?(self.strings, self.plurals, self.errors)
        }
        
        xliffs.forEach { (xliff) in
            let download = CrowdinXliffMappingDownloadOperation(hash: hash, filePath: xliff, sourceLanguage: localization, contentDeliveryAPI: contentDeliveryAPI, completion: { (strings, plurals, error) in
                self.add(error: error)
                self.add(strings: strings)
                self.add(plurals: plurals)
            })
            completionBlock.addDependency(download)
            operationQueue.addOperation(download)
        }
        
        strings.forEach { (string) in
            let download = CrowdinStringsMappingDownloadOperation(hash: hash, filePath: string, sourceLanguage: localization, contentDeliveryAPI: contentDeliveryAPI, completion: { (strings, error) in
                self.add(error: error)
                self.add(strings: strings)
            })
            completionBlock.addDependency(download)
            operationQueue.addOperation(download)
        }
        
        plurals.forEach { (plural) in
            let download = CrowdinPluralsMappingDownloadOperation(hash: hash, filePath: plural, sourceLanguage: localization, contentDeliveryAPI: contentDeliveryAPI, completion: { (plurals, error) in
                self.add(error: error)
                self.add(plurals: plurals)
            })
            completionBlock.addDependency(download)
            operationQueue.addOperation(download)
        }
        operationQueue.addOperation(completionBlock)
    }
    
    func getFiles(for hash: String, completion: @escaping ([String]?, TimeInterval?, Error?) -> Void) {
        self.contentDeliveryAPI = CrowdinContentDeliveryAPI(hash: hash, session: URLSession.init(configuration: .ephemeral))
        self.contentDeliveryAPI.getManifest { (manifest, error) in
            completion(manifest?.files, manifest?.timestamp, error)
        }
    }
    
    func add(error: Error?) {
        guard let error = error else { return }
        if self.errors != nil {
            self.errors?.append(error)
        } else {
            self.errors = [error]
        }
    }
    
    func add(strings: [String: String]?) {
        guard let strings = strings else { return }
        if self.strings != nil {
            self.strings?.merge(with: strings)
        } else {
            self.strings = strings
        }
    }
    
    func add(plurals: [AnyHashable: Any]?) {
        guard let plurals = plurals else { return }
        if self.plurals != nil {
            self.plurals?.merge(with: plurals)
        } else {
            self.plurals = plurals
        }
    }
}
