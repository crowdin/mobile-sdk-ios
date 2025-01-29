//
//  CrowdinPluralsDownloadOperation.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 05.12.2019.
//

import Foundation

class CrowdinPluralsDownloadOperation: CrowdinDownloadOperation {
    var completion: (([AnyHashable: Any]?, Error?) -> Void)? = nil
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
        contentDeliveryAPI.getPlurals(filePath: filePath, etag: etag, timestamp: timestamp, completion: { [weak self] (plurals, etag, error) in
            guard let self = self else { return }
            self.eTagStorage.save(etag: etag, for: self.filePath)
            self.completion?(plurals, error)
            self.finish(with: error != nil)
        })
    }
}
