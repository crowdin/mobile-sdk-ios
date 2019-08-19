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
	var loginConfig: CrowdinLoginConfig
    
    public init(login: String, accountKey: String, loginConfig: CrowdinLoginConfig) {
        self.login = login
        self.accountKey = accountKey
		self.loginConfig = loginConfig
        super.init()
    }
}
