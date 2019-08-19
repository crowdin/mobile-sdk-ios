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
    
    func baseURL() -> String {
        return "https://crowdin.com/api/v2/distributions/metadata?hash=\(hashString)"
    }

    func getDistribution(completion: @escaping (DistributionsResponse?, Error?) -> Void) {
        self.cw_get(url: baseURL(), completion: completion)
    }
}
