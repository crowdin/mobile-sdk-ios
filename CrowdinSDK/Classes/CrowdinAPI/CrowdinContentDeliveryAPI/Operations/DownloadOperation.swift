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
    
    fileprivate var expectedContentLength: Int64 = 0
    fileprivate var currentContentLength: Int64 = 0
    
    required init(hash: String, filePath: String) {
        self.hashString = hash
        self.filePath = CrowdinPathsParser.shared.parse(filePath)
        self.session = URLSession(configuration: .ephemeral)
    }
    
    override func main() {
        fatalError("Please use child classes: CrowdinStringsDownloadOperation, CrowdinPluralsDownloadOperation")
    }
}

class CrowdinPluralsDownloadOperation: CrowdinDownloadOperation {
    var completion: (([AnyHashable: Any]?, Error?) -> Void)? = nil
    var plurals: [AnyHashable: Any]?
    
    init(hash: String, file: String, localization: String, completion: (([AnyHashable: Any]?, Error?) -> Void)?) {
        super.init(hash: hash, filePath: file)
        self.completion = completion
    }
    
    required init(hash: String, filePath: String) {
        super.init(hash: hash, filePath: filePath)
    }
    
    override func main() {
        let result = CrowdinContentDeliveryAPI(hash: self.hashString, session: self.session).getPluralsSync(filePath: self.filePath)
        self.plurals = result.plurapls
        self.error = result.error
        self.completion?(self.plurals, self.error)
        self.finish(with: result.error != nil)
    }
}

class CrowdinStringsDownloadOperation: CrowdinDownloadOperation {
    var completion: (([String: String]?, Error?) -> Void)? = nil
    var strings: [String: String]?
    
    init(hash: String, filePath: String, localization: String, completion: (([AnyHashable: Any]?, Error?) -> Void)?) {
        super.init(hash: hash, filePath: filePath)
        self.completion = completion
    }
    
    required init(hash: String, filePath: String) {
        super.init(hash: hash, filePath: filePath)
    }
    
    override func main() {
        let result = CrowdinContentDeliveryAPI(hash: self.hashString, session: self.session).getStringsSync(filePath: filePath)
        self.strings = result.strings
        self.error = result.error
        self.completion?(self.strings, self.error)
        self.finish(with: result.error != nil)
    }
}
