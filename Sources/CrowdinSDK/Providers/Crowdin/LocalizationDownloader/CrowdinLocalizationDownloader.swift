//
//  CrowdinDownloader.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/24/19.
//

import Foundation

class CrowdinLocalizationDownloader: CrowdinDownloaderProtocol {
    // Context to safe data during download
    class DownloadContext {
        var strings: [String: String]?
        var plurals: [AnyHashable: Any]?
        var errors: [Error]?
        let lock = NSLock()
        
        func add(error: Error?) {
            guard let error = error else { return }
            lock.lock()
            if self.errors != nil {
                self.errors?.append(error)
            } else {
                self.errors = [error]
            }
            lock.unlock()
        }
        
        func add(strings: [String: String]?) {
            guard let strings = strings else { return }
            lock.lock()
            if self.strings != nil {
                self.strings?.merge(with: strings)
            } else {
                self.strings = strings
            }
            lock.unlock()
        }
        
        func add(plurals: [AnyHashable: Any]?) {
            guard let plurals = plurals else { return }
            lock.lock()
            if self.plurals != nil {
                self.plurals?.merge(with: plurals)
            } else {
                self.plurals = plurals
            }
            lock.unlock()
        }
    }
    
    fileprivate let operationQueue = OperationQueue()
    fileprivate var contentDeliveryAPI: CrowdinContentDeliveryAPI!
    fileprivate let manifestManager: ManifestManager
    
    init(manifestManager: ManifestManager) {
        self.manifestManager = manifestManager
    }

    func download(with hash: String, for localization: String, completion: @escaping CrowdinDownloaderCompletion) {
        self.getFiles(for: localization) { [weak self] (files, timestamp, error) in
            guard let self = self else { return }
            if let files = files {
                let context = DownloadContext()
                
                let xcstringsFiles = files.filter({ $0.isXcstrings })
                // For xcstrings we need to parse existing files when localization is changed, otherwise we wont get localization strings from xcstrings files.
                self.parseXCStrings(files: xcstringsFiles, for: localization, context: context)
                let notXcstringsFiles = files.filter({ !$0.isXcstrings })
                let notXcstringsFilesToDownload = notXcstringsFiles.filter { self.manifestManager.hasFileChanged(filePath: $0, localization: localization) }
                let xcStringsFilesToDownlaod = xcstringsFiles.filter({ self.manifestManager.hasFileChanged(filePath: $0, localization: self.manifestManager.xcstringsLanguage) })
                let filesToDownload = xcStringsFilesToDownlaod + notXcstringsFilesToDownload
                if !filesToDownload.isEmpty {
                    self.download(strings: filesToDownload.filter({ $0.isStrings }),
                                  plurals: filesToDownload.filter({ $0.isStringsDict }),
                                  xliffs: filesToDownload.filter({ $0.isXliff }),
                                  xcstrings: filesToDownload.filter({ $0.isXcstrings }),
                                  with: hash, timestamp: timestamp, for: localization, context: context, completion: completion)
                } else {
                    completion(context.strings, context.plurals, context.errors)
                }
            } else if let error = error {
                completion(nil, nil, [error])
            }
        }
    }

    func download(strings: [String],
                  plurals: [String],
                  xliffs: [String],
                  xcstrings: [String],
                  with hash: String,
                  timestamp: TimeInterval?,
                  for localization: String,
                  context: DownloadContext,
                  completion: @escaping CrowdinDownloaderCompletion) {
        let timestamp = timestamp ?? Date().timeIntervalSince1970
        // Cancel all operations only if needed. For concurrent downloads we might not want to cancel everything.
        // self.operationQueue.cancelAllOperations()

        self.contentDeliveryAPI = CrowdinContentDeliveryAPI(hash: hash, session: URLSession.shared)
        
        let completionBlock = BlockOperation {
            context.lock.lock()
            completion(context.strings, context.plurals, context.errors)
            context.lock.unlock()
        }

        strings.forEach { filePath in
            let download = CrowdinStringsDownloadOperation(filePath: filePath, localization: localization, timestamp: timestamp, contentDeliveryAPI: contentDeliveryAPI)
            download.completion = { [weak self] (strings, error) in
                guard let self = self else { return }
                context.add(strings: strings)
                context.add(error: error)
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
                context.add(plurals: plurals)
                context.add(error: error)
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
                context.add(strings: strings)
                context.add(plurals: plurals)
                context.add(error: error)
                if error == nil {
                    self.updateTimestamp(for: localization, filePath: filePath, timestamp: timestamp)
                }
            }
            completionBlock.addDependency(download)
            operationQueue.addOperation(download)
        }

        xcstrings.forEach { filePath in
            let download = CrowdinXcstringsDownloadOperation(filePath: filePath,
                                                             localization: localization,
                                                             xcstringsLanguage: manifestManager.xcstringsLanguage,
                                                             timestamp: timestamp,
                                                             contentDeliveryAPI: contentDeliveryAPI)
            download.completion = { [weak self] (strings, plurals, error) in
                guard let self = self else { return }
                context.add(strings: strings)
                context.add(plurals: plurals)
                context.add(error: error)
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
    
    func updateTimestamp(for localization: String, filePath: String, timestamp: TimeInterval) {
        manifestManager.fileTimestampStorage.updateTimestamp(for: localization, filePath: filePath, timestamp: timestamp)
        manifestManager.fileTimestampStorage.saveTimestamps()
    }
    
    private func parseXCStrings(files: [String], for localization: String, context: DownloadContext) {
        for xcstringsFile in files {
            if let data = XCStringsStorage.getFile(path: xcstringsFile) {
                let parsed = XcstringsParser.parse(data: data, localization: localization)
                context.add(strings: parsed.strings)
                context.add(plurals: parsed.plurals)
                context.add(error: parsed.error)
            }
        }
    }
}
