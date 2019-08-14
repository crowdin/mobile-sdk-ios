//
//  DistributionsAPI.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/19/19.
//

import Foundation

class DistributionsAPI: CrowdinAPI {
    let hashString: String
    
    init(hashString: String) {
        self.hashString = hashString
        super.init()
    }
    
    enum ParameterKeys: String {
        case userAgent = "User-Agent"
        case cookie = "Cookie"
        case xCsrfToken = "x-csrf-token"
    }
    
    func baseURL() -> String {
        return "https://crowdin.com/api/v2/distributions/metadata?hash=\(hashString)"
    }

    func getDistribution(completion: @escaping (DistributionsResponse?, Error?) -> Void) {
        self.cw_get(url: baseURL(), headers: self.headers, completion: completion)
    }
    
    func getDistributionSync(completion: @escaping (DistributionsResponse?, Error?) -> Void) {
        self.cw_get(url: baseURL(), headers: self.headers, completion: completion)
    }
    
    var headers: [String: String] {
        guard let accessToken = LoginFeature.accessToken else { return [:] }
        return ["Authorization": "Bearer \(accessToken)"]
    }
}
