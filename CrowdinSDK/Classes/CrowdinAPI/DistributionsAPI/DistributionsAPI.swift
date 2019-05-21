//
//  DistributionsAPI.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/19/19.
//

import Foundation

class DistributionsAPI: CrowdinAPI {
    let hashString: String
    let csrfToken: String
    let userAgent: String
    let cookies: [HTTPCookie]
    
    init(hashString: String, csrfToken: String, userAgent: String, cookies: [HTTPCookie]) {
        self.hashString = hashString
        self.csrfToken = csrfToken
        self.userAgent = userAgent
        self.cookies = cookies
        
        super.init()
    }
    
    enum ParameterKeys: String {
        case userAgent = "User-Agent"
        case cookie = "Cookie"
        case xCsrfToken = "x-csrf-token"
    }
    
    func baseURL() -> String {
        return "https://crowdin.com/backend/distributions/get_info?distribution_hash=\(hashString)"
    }
    
    var cookiesString: String {
        var cookiesString = ""
        for cookie in cookies {
            cookiesString += "\(cookie.name)=\(cookie.value); "
        }
        return cookiesString
    }
    
    func getDistribution(completion: @escaping (DistributionsResponse?, Error?) -> Void) {
        let headers = [ParameterKeys.userAgent.rawValue: userAgent, ParameterKeys.cookie.rawValue: cookiesString, ParameterKeys.xCsrfToken.rawValue: csrfToken]
        self.cw_get(url: baseURL(), headers: headers, completion: completion)
    }
    
    func getDistributionSync(completion: @escaping (DistributionsResponse?, Error?) -> Void) {
        let headers = [ParameterKeys.userAgent.rawValue: userAgent, ParameterKeys.cookie.rawValue: cookiesString, ParameterKeys.xCsrfToken.rawValue: csrfToken]
        self.cw_get(url: baseURL(), headers: headers, completion: completion)
    }
}
