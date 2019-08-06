//
//  TokenRequest.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 8/6/19.
//

import Foundation

struct TokenRequest: Codable {
	var grant_type: String = "authorization_code"
	var client_id: String = "test-sdk"
	var client_secret: String = "79MG6E8DZfEeomalfnoKx7dA0CVuwtPC3jQTB3ts"
	var code: String
	
	init(code: String) {
		self.code = code
	}
}
