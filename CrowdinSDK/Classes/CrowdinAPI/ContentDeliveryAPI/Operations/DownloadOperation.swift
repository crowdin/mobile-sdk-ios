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
    var session: URLSession
    
    required init(hash: String, filePath: String) {
        self.hashString = hash
        self.filePath = filePath
        self.session = URLSession(configuration: .ephemeral)
    }
    
    override func main() {
        fatalError("Please use child classes: CrowdinStringsDownloadOperation, CrowdinPluralsDownloadOperation")
    }
}

class CrowdinPluralsDownloadOperation: CrowdinDownloadOperation {
    var completion: (([AnyHashable: Any]?, Error?) -> Void)? = nil
    var plurals: [AnyHashable: Any]?
    
    init(hash: String, filePath: String, localization: String, completion: (([AnyHashable: Any]?, Error?) -> Void)?) {
        super.init(hash: hash, filePath: CrowdinPathsParser.shared.parse(filePath))
        self.completion = completion
    }
    
    required init(hash: String, filePath: String) {
        super.init(hash: hash, filePath: CrowdinPathsParser.shared.parse(filePath))
    }
    
    override func main() {
        let result = CrowdinContentDeliveryAPI(hash: self.hashString, session: self.session).getPluralsSync(filePath: self.filePath)
        self.plurals = result.plurals
        self.error = result.error
        self.completion?(self.plurals, self.error)
        self.finish(with: result.error != nil)
    }
}

class CrowdinStringsDownloadOperation: CrowdinDownloadOperation {
    var completion: (([String: String]?, Error?) -> Void)? = nil
    var strings: [String: String]?
    
    init(hash: String, filePath: String, localization: String, completion: (([AnyHashable: Any]?, Error?) -> Void)?) {
        super.init(hash: hash, filePath: CrowdinPathsParser.shared.parse(filePath))
        self.completion = completion
    }
    
    required init(hash: String, filePath: String) {
        super.init(hash: hash, filePath: CrowdinPathsParser.shared.parse(filePath))
    }
    
    override func main() {
        let result = CrowdinContentDeliveryAPI(hash: self.hashString, session: self.session).getStringsSync(filePath: filePath)
        self.strings = result.strings
        self.error = result.error
        self.completion?(self.strings, self.error)
        self.finish(with: result.error != nil)
    }
}

class CrowdinPluralsMappingDownloadOperation: CrowdinDownloadOperation {
    var completion: (([AnyHashable: Any]?, Error?) -> Void)? = nil
    var plurals: [AnyHashable: Any]?
    
    init(hash: String, filePath: String, sourceLanguage: String, completion: (([AnyHashable: Any]?, Error?) -> Void)?) {
        let fileName = String(filePath.split(separator: "/").last ?? "")
        super.init(hash: hash, filePath: "/\(sourceLanguage)/\(fileName)")
        self.completion = completion
    }
    
    required init(hash: String, filePath: String) {
        super.init(hash: hash, filePath: filePath)
    }
    
    override func main() {
        let result = CrowdinContentDeliveryAPI(hash: self.hashString, session: self.session).getPluralsMappingSync(filePath: self.filePath)
        self.plurals = result.plurals
        self.error = result.error
        self.completion?(self.plurals, self.error)
        self.finish(with: result.error != nil)
    }
}

class CrowdinStringsMappingDownloadOperation: CrowdinDownloadOperation {
    var completion: (([String: String]?, Error?) -> Void)? = nil
    var strings: [String: String]?
    
    init(hash: String, filePath: String, sourceLanguage: String, completion: (([String: String]?, Error?) -> Void)?) {
        let fileName = String(filePath.split(separator: "/").last ?? "")
        super.init(hash: hash, filePath: "/\(sourceLanguage)/\(fileName)")
        self.completion = completion
    }
    
    required init(hash: String, filePath: String) {
        super.init(hash: hash, filePath: filePath)
    }
    
    override func main() {
        let result = CrowdinContentDeliveryAPI(hash: self.hashString, session: self.session).getStringsMappingSync(filePath: filePath)
        self.strings = result.strings
        self.error = result.error
        self.completion?(self.strings, self.error)
        self.finish(with: result.error != nil)
    }
}
