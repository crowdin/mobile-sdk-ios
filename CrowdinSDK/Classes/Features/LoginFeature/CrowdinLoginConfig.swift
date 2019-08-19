//
//  CrowdinLoginConfig.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 8/16/19.
//

import Foundation

public protocol LoginConfig { }

@objcMembers public class CrowdinLoginConfig: NSObject, LoginConfig {
	var clientId: String
	var clientSecret: String
	var scope: String
	var redirectURI: String
	
	public init(clientId: String, clientSecret: String, scope: String, redirectURI: String) {
		self.clientId = clientId
		self.clientSecret = clientSecret
		self.scope = scope
		self.redirectURI = redirectURI
	}
}
