//
//  DownloadOperation.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/24/19.
//

import Foundation

class CrowdinStringsDownloadOperation: CrowdinDownloadOperation {
    var completion: (([String: String]?, Error?) -> Void)? = nil
    var timestamp: TimeInterval?
    var eTagStorage: AnyEtagStorage

    init(filePath: String, localization: String, timestamp: TimeInterval?, contentDeliveryAPI: CrowdinContentDeliveryAPI, completion: (([AnyHashable: Any]?, Error?) -> Void)?) {
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
        contentDeliveryAPI.getStrings(filePath: filePath, etag: etag, timestamp: timestamp) { [weak self] (strings, etag, error) in
            guard let self = self else { return }
            self.eTagStorage.save(etag: etag, for: self.filePath)
            self.completion?(strings, error)
            self.finish(with: error != nil)
        }
    }
}
