//
//  LanguagesAPI.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/26/19.
//

import Foundation

class SupportedLanguagesAPI: CrowdinAPI {
    let parameters = ["json" : ""]
    
    override var apiPath: String { return "supported-languages" }
    
    func buildURL() -> String {
        return "\(baseAPIPath)/\(apiPath)/"
    }
    
    func getSupportedLanguages(completion: (SupportedLanguagesResponse?, Error?) -> Void) {
        let url = buildURL()
        self.cw_get(url: url, parameters: parameters, completion: completion)
    }
    
    func getSupportedLanguagesSync() -> (SupportedLanguagesResponse?, Error?) {
        let url = buildURL()
        return self.cw_get(url: url, parameters: parameters)
        
    }
}
