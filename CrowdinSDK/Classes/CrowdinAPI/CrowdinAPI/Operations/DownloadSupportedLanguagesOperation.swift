//
//  DownloadSupportedLanguagesOperation.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/26/19.
//

import Foundation

class DownloadSupportedLanguagesOperation: AsyncOperation {
    var completion: ((SupportedLanguagesResponse?, Error?) -> Void)? = nil
    
    var error: Error?
    var supportedLanguages: SupportedLanguagesResponse?
    
    override func main() {
        let supportedLanguagesAPI = SupportedLanguagesAPI()
        let response = supportedLanguagesAPI.getSupportedLanguagesSync()
        self.supportedLanguages = response.0
        self.error = response.1
        self.completion?(self.supportedLanguages, self.error)
        self.finish(with: self.error != nil)
    }
}
