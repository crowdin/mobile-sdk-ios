//
//  CrowdinDownloadOperation.swift
//  BaseAPI
//
//  Created by Serhii Londar on 05.12.2019.
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
