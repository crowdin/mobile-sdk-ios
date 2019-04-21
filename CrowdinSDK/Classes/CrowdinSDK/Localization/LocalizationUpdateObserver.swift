//
//  LocalizationUpdateObserver.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/22/19.
//

import Foundation

typealias LocalizationUpdateDownload = () -> Void
typealias LocalizationUpdateError = ([Error]) -> Void

protocol LocalizationUpdateObserverProtocol {
    var downloadHandlers: [UInt: LocalizationUpdateDownload] { get }
    var errorHandlers: [UInt: LocalizationUpdateError] { get }
    
    func subscribe()
    func unsubscribe()
}

class LocalizationUpdateObserver {
    var downloadHandlers: [UInt: LocalizationUpdateDownload] = [:]
    var errorHandlers: [UInt: LocalizationUpdateError] = [:]
    
    init() {
        subscribe()
    }
    
    deinit {
        unsubscribe()
    }
    
    func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDownloadLocalization), name: NSNotification.Name.CrowdinProviderDidDownloadLocalization, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(downloadError(_:)), name: NSNotification.Name.CrowdinProviderDownloadError, object: nil)
    }
    
    func unsubscribe() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addDownloadHandler(_ handler: @escaping LocalizationUpdateDownload) -> UInt {
        let newKey = (downloadHandlers.keys.max() ?? 0) + 1
        downloadHandlers[newKey] = handler
        return newKey
    }
    
    func removeDownloadHandler(_ id: UInt) {
        downloadHandlers.removeValue(forKey: id)
    }
    
    func removeAllDownloadHandlers() {
        downloadHandlers.removeAll()
    }
    
    func addErrorHandler(_ handler: @escaping LocalizationUpdateError) -> UInt {
        let newKey = (errorHandlers.keys.max() ?? 0) + 1
        errorHandlers[newKey] = handler
        return newKey
    }
    
    func removeErrorHandler(_ id: UInt) {
        errorHandlers.removeValue(forKey: id)
    }
    
    func removeAllErrorHandlers() {
        errorHandlers.removeAll()
    }
    
    @objc func didDownloadLocalization() {
        downloadHandlers.forEach({ $1() })
    }
    
    @objc func downloadError(_ errors: [Error]) {
        errorHandlers.forEach({ $1(errors) })
    }
}
