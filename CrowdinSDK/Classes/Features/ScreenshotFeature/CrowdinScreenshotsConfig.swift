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
    
    public init(login: String, accountKey: String) {
        self.login = login
        self.accountKey = accountKey
        super.init()
    }
}
