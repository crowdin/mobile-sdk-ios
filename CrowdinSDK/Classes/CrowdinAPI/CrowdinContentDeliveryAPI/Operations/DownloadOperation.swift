//
//  DownloadOperation.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/24/19.
//

import Foundation

protocol CrowdinDownloadOperationProtocol {
    var hashString: String { get }
    var file: String { get }
    var localization: String { get }
}

class CrowdinDownloadOperation: AsyncOperation, CrowdinDownloadOperationProtocol {
    var error: Error?
    
    var hashString: String
    var file: String
    var localization: String
    var session: URLSession
    
    fileprivate var expectedContentLength: Int64 = 0
    fileprivate var currentContentLength: Int64 = 0
    
    required init(hash: String, file: String, localization: String) {
        self.hashString = hash
        self.file = file
        self.localization = localization
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
        super.init(hash: hash, file: file, localization: localization)
        self.completion = completion
    }
    
    required init(hash: String, file: String, localization: String) {
        super.init(hash: hash, file: file, localization: localization)
    }
    
    override func main() {
        let result = CrowdinContentDeliveryAPI(hash: self.hashString, session: self.session).getPluralsSync(file: self.file, for: localization)
        self.plurals = result.plurapls
        self.error = result.error
        self.completion?(self.plurals, self.error)
        self.finish(with: result.error != nil)
    }
}

class CrowdinStringsDownloadOperation: CrowdinDownloadOperation {
    var completion: (([String: String]?, Error?) -> Void)? = nil
    var strings: [String: String]?
    
    init(hash: String, file: String, localization: String, completion: (([AnyHashable: Any]?, Error?) -> Void)?) {
        super.init(hash: hash, file: file, localization: localization)
        self.completion = completion
    }
    
    required init(hash: String, file: String, localization: String) {
        super.init(hash: hash, file: file, localization: localization)
    }
    
    override func main() {
        let result = CrowdinContentDeliveryAPI(hash: self.hashString, session: self.session).getStringsSync(file: self.file, for: localization)
        self.strings = result.strings
        self.error = result.error
        self.completion?(self.strings, self.error)
        self.finish(with: result.error != nil)
    }
}
