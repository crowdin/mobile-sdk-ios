//
//  CrowdinJsonDownloadOperation.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 05.07.2020.
//

import Foundation

typealias CrowdinJsonDownloadOperationCompletion = ([String: String]?, [AnyHashable: Any]?, Error?) -> Void

class CrowdinJsonDownloadOperation: CrowdinDownloadOperation {
   var completion: CrowdinJsonDownloadOperationCompletion? = nil
   var timestamp: TimeInterval?
   
   init(filePath: String, localization: String, timestamp: TimeInterval?, contentDeliveryAPI: CrowdinContentDeliveryAPI, completion: CrowdinJsonDownloadOperationCompletion?) {
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
        contentDeliveryAPI.getJson(filePath: filePath, etag: etag, timestamp: timestamp) { [weak self] (strings, etag, error) in
            guard let self = self else { return }
            ETagStorage.shared.etags[self.filePath] = etag
            self.completion?(strings, nil, error)
            self.finish(with: error != nil)
        }
    }
}
