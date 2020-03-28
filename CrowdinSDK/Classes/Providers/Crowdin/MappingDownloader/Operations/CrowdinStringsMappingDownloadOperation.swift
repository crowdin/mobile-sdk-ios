//
//  DownloadOperation.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/24/19.
//

import Foundation

class CrowdinStringsMappingDownloadOperation: CrowdinDownloadOperation {
    var completion: (([String: String]?, Error?) -> Void)? = nil
    var strings: [String: String]?
    var error: Error?
    
    init(hash: String, filePath: String, sourceLanguage: String, contentDeliveryAPI: CrowdinContentDeliveryAPI, completion: (([String: String]?, Error?) -> Void)?) {
        let filePath = CrowdinPathsParser.shared.parse(filePath, localization: sourceLanguage)
        super.init(filePath: filePath, contentDeliveryAPI: contentDeliveryAPI)
        self.completion = completion
    }
    
    override init(filePath: String, contentDeliveryAPI: CrowdinContentDeliveryAPI) {
        super.init(filePath: filePath, contentDeliveryAPI: contentDeliveryAPI)
    }
    
    override func main() {
        let result = contentDeliveryAPI.getStringsMappingSync(filePath: filePath)
        self.strings = result.strings
        self.error = result.error
        self.completion?(self.strings, self.error)
        self.finish(with: result.error != nil)
    }
}
