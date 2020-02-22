//
//  CrowdinSDK+Login.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 8/16/19.
//

import Foundation

extension CrowdinSDKConfig {
	private static var loginConfig: CrowdinLoginConfig?
	// Login
	var loginConfig: CrowdinLoginConfig? {
		get {
			return CrowdinSDKConfig.loginConfig
		}
		set {
			CrowdinSDKConfig.loginConfig = newValue
            CrowdinSDKConfig.loginConfig?.organizationName = self.organizationName
		}
	}
	
	public func with(loginConfig: CrowdinLoginConfig) -> Self {
		self.loginConfig = loginConfig
		return self
	}
}
