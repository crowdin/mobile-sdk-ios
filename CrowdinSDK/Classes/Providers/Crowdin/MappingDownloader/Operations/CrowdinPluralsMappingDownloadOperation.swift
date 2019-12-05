//
//  CrowdinPluralsMappingDownloadOperation.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 05.12.2019.
//

import Foundation

class CrowdinPluralsMappingDownloadOperation: CrowdinDownloadOperation {
    var completion: (([AnyHashable: Any]?, Error?) -> Void)? = nil
    var plurals: [AnyHashable: Any]?
    
    init(hash: String, filePath: String, sourceLanguage: String, contentDeliveryAPI: CrowdinContentDeliveryAPI, completion: (([AnyHashable: Any]?, Error?) -> Void)?) {
        let filePath = CrowdinPathsParser.shared.parse(filePath, localization: sourceLanguage)
        super.init(hash: hash, filePath: filePath, contentDeliveryAPI: contentDeliveryAPI)
        self.completion = completion
    }
    
    override init(hash: String, filePath: String, contentDeliveryAPI: CrowdinContentDeliveryAPI) {
        super.init(hash: hash, filePath: filePath, contentDeliveryAPI: contentDeliveryAPI)
    }
    
    override func main() {
        let result = contentDeliveryAPI.getPluralsMappingSync(filePath: self.filePath)
        self.plurals = result.plurals
        self.error = result.error
        self.completion?(self.plurals, self.error)
        self.finish(with: result.error != nil)
    }
}
