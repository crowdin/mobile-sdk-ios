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
    init(hash: String, filePath: String, localization: String, contentDeliveryAPI: CrowdinContentDeliveryAPI, completion: (([AnyHashable: Any]?, Error?) -> Void)?) {
        super.init(hash: hash, filePath: CrowdinPathsParser.shared.parse(filePath, localization: localization), contentDeliveryAPI: contentDeliveryAPI)
        self.completion = completion
    }
    
    required init(hash: String, filePath: String, localization: String, contentDeliveryAPI: CrowdinContentDeliveryAPI) {
        super.init(hash: hash, filePath: CrowdinPathsParser.shared.parse(filePath, localization: localization), contentDeliveryAPI: contentDeliveryAPI)
    }
    
    override func main() {
        let result = contentDeliveryAPI.getPluralsSync(filePath: self.filePath)
        self.plurals = result.plurals
        self.error = result.error
        self.completion?(self.plurals, self.error)
        self.finish(with: result.error != nil)
    }
}
