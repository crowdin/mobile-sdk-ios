//
//  CrowdinDownloader.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/24/19.
//

import Foundation

class CrowdinLocalizationDownloader: CrowdinDownloaderProtocol {
    // swiftlint:disable implicitly_unwrapped_optional
    var completion: CrowdinDownloaderCompletion? = nil

    fileprivate let operationQueue = OperationQueue()
    fileprivate var strings: [String: String]? = nil
    fileprivate var plurals: [AnyHashable: Any]? = nil
    fileprivate var errors: [Error]? = nil
    fileprivate var contentDeliveryAPI: CrowdinContentDeliveryAPI!
    fileprivate let manifestManager: ManifestManager

    init(manifestManager: ManifestManager) {
        self.manifestManager = manifestManager
    }

    func download(with hash: String, for localization: String, completion: @escaping CrowdinDownloaderCompletion) {
        self.completion = completion
        self.getFiles(for: localization) { [weak self] (files, timestamp, error) in
            guard let self = self else { return }
            if let files = files {
                let xcstringsFiles = files.filter({ $0.isXcstrings })
                let notXcstringsFiles = files.filter({ !$0.isXcstrings })
                let notXcstringsFilesToDownload = notXcstringsFiles.filter { self.manifestManager.hasFileChanged(filePath: $0, localization: localization) }
                let xcStringsFilesToDownlaod = xcstringsFiles.filter({ self.manifestManager.hasFileChanged(filePath: $0, localization: self.manifestManager.xcstringsLanguage) })
                let filesToDownload = xcStringsFilesToDownlaod + notXcstringsFilesToDownload
                if !filesToDownload.isEmpty {
                    self.download(strings: filesToDownload.filter({ $0.isStrings }),
                                  plurals: filesToDownload.filter({ $0.isStringsDict }),
                                  xliffs: filesToDownload.filter({ $0.isXliff }),
                                  xcstrings: filesToDownload.filter({ $0.isXcstrings }),
                                  with: hash, timestamp: timestamp, for: localization)
                } else {
                    self.completion?(nil, nil, nil)
                }
            } else if let error = error {
                self.errors = [error]
                self.completion?(nil, nil, self.errors)
            }
        }
    }

    func download(strings: [String], plurals: [String], xliffs: [String], xcstrings: [String], with hash: String, timestamp: TimeInterval?, for localization: String) {
        let timestamp = timestamp ?? Date().timeIntervalSince1970
        self.operationQueue.cancelAllOperations()

        self.contentDeliveryAPI = CrowdinContentDeliveryAPI(hash: hash, session: URLSession.shared)
        self.strings = nil
        self.plurals = nil
        self.errors = nil

        let completionBlock = BlockOperation { [weak self] in
            guard let self = self else { return }
            self.completion?(self.strings, self.plurals, self.errors)
        }

        strings.forEach { filePath in
            let download = CrowdinStringsDownloadOperation(filePath: filePath, localization: localization, timestamp: timestamp, contentDeliveryAPI: contentDeliveryAPI)
            download.completion = { [weak self] (strings, error) in
                guard let self = self else { return }
                self.add(strings: strings)
                self.add(error: error)
                if error == nil {
                    self.updateTimestamp(for: localization, filePath: filePath, timestamp: timestamp)
                }
            }
            completionBlock.addDependency(download)
            operationQueue.addOperation(download)
        }

        plurals.forEach { filePath in
            let download = CrowdinPluralsDownloadOperation(filePath: filePath, localization: localization, timestamp: timestamp, contentDeliveryAPI: contentDeliveryAPI)
            download.completion = { [weak self] (plurals, error) in
                guard let self = self else { return }
                self.add(plurals: plurals)
                self.add(error: error)
                if error == nil {
                    self.updateTimestamp(for: localization, filePath: filePath, timestamp: timestamp)
                }
            }
            completionBlock.addDependency(download)
            operationQueue.addOperation(download)
        }

        xliffs.forEach { filePath in
            let download = CrowdinXliffDownloadOperation(filePath: filePath, localization: localization, timestamp: timestamp, contentDeliveryAPI: contentDeliveryAPI)
            download.completion = { [weak self] (strings, plurals, error) in
                guard let self = self else { return }
                self.add(strings: strings)
                self.add(plurals: plurals)
                self.add(error: error)
                if error == nil {
                    self.updateTimestamp(for: localization, filePath: filePath, timestamp: timestamp)
                }
            }
            completionBlock.addDependency(download)
            operationQueue.addOperation(download)
        }

        xcstrings.forEach { filePath in
            let download = CrowdinXcstringsDownloadOperation(filePath: filePath,
                                                             localization: manifestManager.xcstringsLanguage,
                                                             timestamp: timestamp,
                                                             contentDeliveryAPI: contentDeliveryAPI)
            download.completion = { [weak self] (strings, plurals, error) in
                guard let self = self else { return }
                self.add(strings: strings)
                self.add(plurals: plurals)
                self.add(error: error)
                if error == nil {
                    self.updateTimestamp(for: self.manifestManager.xcstringsLanguage, filePath: filePath, timestamp: timestamp)
                }
            }
            completionBlock.addDependency(download)
            operationQueue.addOperation(download)
        }

        operationQueue.operations.forEach({ $0.qualityOfService = .userInitiated })
        operationQueue.addOperation(completionBlock)
    }

    func getFiles(for language: String, completion: @escaping ([String]?, TimeInterval?, Error?) -> Void) {
        manifestManager.download { [weak self] in
            guard let self = self else { return }
            completion(self.manifestManager.contentFiles(for: language), self.manifestManager.timestamp, nil)
        }
    }

    func getLanguages(for hash: String, completion: @escaping ([String]?, Error?) -> Void) {
        manifestManager.download { [weak self] in
            guard let self = self else { return }
            completion(self.manifestManager.languages, nil)
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
    
    func updateTimestamp(for localization: String, filePath: String, timestamp: TimeInterval) {
        manifestManager.fileTimestampStorage.updateTimestamp(for: localization, filePath: filePath, timestamp: timestamp)
        manifestManager.fileTimestampStorage.saveTimestamps()
    }
}
