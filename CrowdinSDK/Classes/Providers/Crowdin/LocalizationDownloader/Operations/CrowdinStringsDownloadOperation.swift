//
//  DownloadOperation.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/24/19.
//

import Foundation

class CrowdinStringsDownloadOperation: CrowdinDownloadOperation {
    var completion: (([String: String]?, Error?) -> Void)? = nil
    var strings: [String: String]?
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
        contentDeliveryAPI.getStrings(filePath: filePath, etag: etag, timestamp: timestamp) { [weak self] (strings, etag, error) in
            guard let self = self else { return }
            ETagStorage.shared.etags[self.filePath] = etag
            self.strings = strings
            self.error = error
            self.completion?(self.strings, self.error)
            self.finish(with: error != nil)
        }
    }
}
