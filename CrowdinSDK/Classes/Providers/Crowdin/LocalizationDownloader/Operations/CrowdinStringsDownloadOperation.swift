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
    
    init(hash: String, filePath: String, localization: String, contentDeliveryAPI: CrowdinContentDeliveryAPI, completion: (([AnyHashable: Any]?, Error?) -> Void)?) {
        super.init(hash: hash, filePath: CrowdinPathsParser.shared.parse(filePath, localization: localization), contentDeliveryAPI: contentDeliveryAPI)
        self.completion = completion
    }
    
    required init(hash: String, filePath: String, localization: String, contentDeliveryAPI: CrowdinContentDeliveryAPI) {
        super.init(hash: hash, filePath: CrowdinPathsParser.shared.parse(filePath, localization: localization), contentDeliveryAPI: contentDeliveryAPI)
    }
    
    override func main() {
        let result = contentDeliveryAPI.getStringsSync(filePath: filePath)
        self.strings = result.strings
        self.error = result.error
        self.completion?(self.strings, self.error)
        self.finish(with: result.error != nil)
    }
}
