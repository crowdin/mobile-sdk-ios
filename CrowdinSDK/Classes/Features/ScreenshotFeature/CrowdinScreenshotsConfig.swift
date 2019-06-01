//
//  CrowdinScreenshotsConfig.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 6/1/19.
//

import Foundation

@objcMembers public class CrowdinScreenshotsConfig: NSObject {
    var login: String
    var accountKey: String
    var credentials: String
    
    public init(login: String, accountKey: String, credentials: String) {
        self.login = login
        self.accountKey = accountKey
        self.credentials = credentials
        super.init()
    }
}
