//
//  LanguagesAPI.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/26/19.
//

import Foundation

class SupportedLanguagesAPI: CrowdinAPI {
    enum Strings: String {
        case json
        case supportedLanguages = "supported-languages"
    }
    
    override var baseURL: String {
        return "https://api.crowdin.com/api/"
    }
    
    let parameters = [Strings.json.rawValue: String.empty]
    
    override var apiPath: String { return Strings.supportedLanguages.rawValue }
    
    func getSupportedLanguages(completion: @escaping (SupportedLanguagesResponse?, Error?) -> Void) {
        self.cw_get(url: fullPath, parameters: parameters, completion: completion)
    }
    
    func getSupportedLanguagesSync() -> (SupportedLanguagesResponse?, Error?) {
        return self.cw_get(url: fullPath, parameters: parameters)
    }
}
