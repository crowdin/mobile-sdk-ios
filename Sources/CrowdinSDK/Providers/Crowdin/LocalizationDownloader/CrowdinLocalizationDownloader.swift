//
//  CrowdinDownloader.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/24/19.
//

import Foundation

class CrowdinLocalizationDownloader: CrowdinDownloaderProtocol {
    fileprivate let operationQueue = OperationQueue()
    fileprivate let manifestManager: ManifestManager
    
    class DownloadContext {
        private var _strings: [String: String]? = nil
        private var _plurals: [AnyHashable: Any]? = nil
        private var _errors: [Error]? = nil
        let lock = NSLock()
        
        var strings: [String: String]? {
            lock.lock()
            defer { lock.unlock() }
            return _strings
        }
        
        var plurals: [AnyHashable: Any]? {
            lock.lock()
            defer { lock.unlock() }
            return _plurals
        }
        
        var errors: [Error]? {
            lock.lock()
            defer { lock.unlock() }
            return _errors
        }
        
        func add(error: Error?) {
            guard let error = error else { return }
            lock.lock()
            if self._errors != nil {
                self._errors?.append(error)
            } else {
                self._errors = [error]
            }
            lock.unlock()
        }
        
        func add(strings: [String: String]?) {
            guard let strings = strings else { return }
            lock.lock()
            if self._strings != nil {
                self._strings?.merge(with: strings)
            } else {
                self._strings = strings
            }
            lock.unlock()
        }
        
        func add(plurals: [AnyHashable: Any]?) {
            guard let plurals = plurals else { return }
            lock.lock()
            if self._plurals != nil {
                self._plurals?.merge(with: plurals)
            } else {
                self._plurals = plurals
            }
            lock.unlock()
        }
    }

    init(manifestManager: ManifestManager) {
        self.manifestManager = manifestManager
    }

    func download(with hash: String, for localization: String, completion: @escaping CrowdinDownloaderCompletion) {
        let context = DownloadContext()
        self.getFiles(for: localization) { [weak self] (files, timestamp, error) in
            guard let self = self else { return }
            if let files = files {
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
                context.add(error: error)
                completion(nil, nil, context.errors)
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
        // Cancel any pending operations to prevent resource leaks from overlapping downloads
        operationQueue.cancelAllOperations()

        let contentDeliveryAPI = CrowdinContentDeliveryAPI(hash: hash, session: URLSession.shared)
        
        let completionBlock = BlockOperation {
            completion(context.strings, context.plurals, context.errors)
        }

        strings.forEach { filePath in
            let download = CrowdinStringsDownloadOperation(filePath: filePath, localization: localization, timestamp: timestamp, contentDeliveryAPI: contentDeliveryAPI)
            download.completion = { [weak self] (strings, error) in
                context.add(strings: strings)
                context.add(error: error)
                guard let self = self else { return }
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
                context.add(plurals: plurals)
                context.add(error: error)
                guard let self = self else { return }
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
                context.add(strings: strings)
                context.add(plurals: plurals)
                context.add(error: error)
                guard let self = self else { return }
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
                context.add(strings: strings)
                context.add(plurals: plurals)
                context.add(error: error)
                guard let self = self else { return }
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
            guard self.manifestManager.manifest != nil else {
                let error = NSError(domain: "Manifest download failed", code: defaultCrowdinErrorCode, userInfo: nil)
                completion(nil, nil, error)
                return
            }
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
