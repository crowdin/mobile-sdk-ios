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
    let parameters = [Strings.json.rawValue: String.empty]
    
    override var apiPath: String { return Strings.supportedLanguages.rawValue }
    
    func buildURL() -> String {
        return "\(baseAPIPath)/\(apiPath)/"
    }
    
    func getSupportedLanguages(completion: @escaping (SupportedLanguagesResponse?, Error?) -> Void) {
        let url = buildURL()
        self.cw_get(url: url, parameters: parameters, completion: completion)
    }
    
    func getSupportedLanguagesSync() -> (SupportedLanguagesResponse?, Error?) {
        let url = buildURL()
        return self.cw_get(url: url, parameters: parameters)
    }
}
