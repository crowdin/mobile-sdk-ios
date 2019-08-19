//
//  CrowdinSDK+Login.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 8/16/19.
//

import Foundation

extension CrowdinSDKConfig {
	private static var loginConfig: LoginConfig?
	// Login
	var loginConfig: LoginConfig? {
		get {
			return CrowdinSDKConfig.loginConfig
		}
		set {
			CrowdinSDKConfig.loginConfig = newValue
		}
	}
	
	public func with(loginConfig: LoginConfig) -> Self {
		self.loginConfig = loginConfig
		return self
	}
}
