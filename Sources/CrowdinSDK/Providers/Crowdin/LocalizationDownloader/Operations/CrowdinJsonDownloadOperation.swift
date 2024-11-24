//
//  CrowdinJsonDownloadOperation.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 05.07.2020.
//

import Foundation

typealias CrowdinJsonDownloadOperationCompletion = ([String: String]?, [AnyHashable: Any]?, Error?) -> Void

class CrowdinJsonDownloadOperation: CrowdinDownloadOperation {
    var timestamp: TimeInterval?
    var eTagStorage: AnyEtagStorage
    var completion: CrowdinJsonDownloadOperationCompletion?

    init(filePath: String, localization: String, timestamp: TimeInterval?, contentDeliveryAPI: CrowdinContentDeliveryAPI, completion: CrowdinJsonDownloadOperationCompletion?) {
        self.timestamp = timestamp
        self.eTagStorage = FileEtagStorage(localization: localization)
        super.init(filePath: filePath, contentDeliveryAPI: contentDeliveryAPI)
        self.completion = completion
    }

    required init(filePath: String, localization: String, timestamp: TimeInterval?, contentDeliveryAPI: CrowdinContentDeliveryAPI) {
        self.timestamp = timestamp
        self.eTagStorage = FileEtagStorage(localization: localization)
        super.init(filePath: filePath, contentDeliveryAPI: contentDeliveryAPI)
    }

    override func main() {
        let etag = eTagStorage.etag(for: filePath)
        contentDeliveryAPI.getJson(filePath: filePath, etag: etag, timestamp: timestamp) { [weak self] (strings, etag, error) in
            guard let self = self else { return }
            self.eTagStorage.save(etag: etag, for: self.filePath)
            self.completion?(strings, nil, error)
            self.finish(with: error != nil)
        }
    }
}
