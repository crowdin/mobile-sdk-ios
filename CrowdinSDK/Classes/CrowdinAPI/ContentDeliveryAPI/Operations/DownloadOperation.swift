//
//  DownloadOperation.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/24/19.
//

import Foundation

protocol CrowdinDownloadOperationProtocol {
    var hashString: String { get }
    var filePath: String { get }
}

class CrowdinDownloadOperation: AsyncOperation, CrowdinDownloadOperationProtocol {
    var error: Error?
    
    var hashString: String
    var filePath: String
    var contentDeliveryAPI: CrowdinContentDeliveryAPI
    
    init(hash: String, filePath: String, contentDeliveryAPI: CrowdinContentDeliveryAPI) {
        self.hashString = hash
        self.filePath = filePath
        self.contentDeliveryAPI = contentDeliveryAPI
    }
    
    override func main() {
        fatalError("Please use child classes: CrowdinStringsDownloadOperation, CrowdinPluralsDownloadOperation")
    }
}

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

class CrowdinStringsMappingDownloadOperation: CrowdinDownloadOperation {
    var completion: (([String: String]?, Error?) -> Void)? = nil
    var strings: [String: String]?
    
    init(hash: String, filePath: String, sourceLanguage: String, contentDeliveryAPI: CrowdinContentDeliveryAPI, completion: (([String: String]?, Error?) -> Void)?) {
        let filePath = CrowdinPathsParser.shared.parse(filePath, localization: sourceLanguage)
        super.init(hash: hash, filePath: filePath, contentDeliveryAPI: contentDeliveryAPI)
        self.completion = completion
    }
    
    override init(hash: String, filePath: String, contentDeliveryAPI: CrowdinContentDeliveryAPI) {
        super.init(hash: hash, filePath: filePath, contentDeliveryAPI: contentDeliveryAPI)
    }
    
    override func main() {
        let result = contentDeliveryAPI.getStringsMappingSync(filePath: filePath)
        self.strings = result.strings
        self.error = result.error
        self.completion?(self.strings, self.error)
        self.finish(with: result.error != nil)
    }
}
