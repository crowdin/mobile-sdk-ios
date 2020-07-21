//
//  CrowdinPluralsDownloadOperation.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 05.12.2019.
//

import Foundation

class CrowdinPluralsDownloadOperation: CrowdinDownloadOperation {
    var completion: (([AnyHashable: Any]?, Error?) -> Void)? = nil
    var plurals: [AnyHashable: Any]?
    var error: Error?
    var timestamp: TimeInterval?
    
    init(filePath: String, localization: String, timestamp: TimeInterval?, contentDeliveryAPI: CrowdinContentDeliveryAPI, completion: (([AnyHashable: Any]?, Error?) -> Void)?) {
        self.timestamp = timestamp
        super.init(filePath: CrowdinPathsParser.shared.parse(filePath, localization: localization), contentDeliveryAPI: contentDeliveryAPI)
        self.completion = completion
    }
    
    required init(filePath: String, localization: String, timestamp: TimeInterval?, contentDeliveryAPI: CrowdinContentDeliveryAPI) {
        self.timestamp = timestamp
        super.init(filePath: CrowdinPathsParser.shared.parse(filePath, localization: localization), contentDeliveryAPI: contentDeliveryAPI)
    }
    
    override func main() {
        let etag = ETagStorage.shared.etags[self.filePath]
        contentDeliveryAPI.getPlurals(filePath: self.filePath, etag: etag, timestamp: nil,completion: { [weak self] (plurals, etag, error) in
            guard let self = self else { return }
            ETagStorage.shared.etags[self.filePath] = etag
            self.plurals = plurals
            self.error = error
            self.completion?(self.plurals, self.error)
            self.finish(with: error != nil)
        })
    }
}
