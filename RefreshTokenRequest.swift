//
//  RefreshTokenRequest.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 8/12/19.
//

import Foundation

struct RefreshTokenRequest: Codable {
	var grant_type: String = "refresh_token"
	var client_id: String = "test-sdk"
	var client_secret: String = "79MG6E8DZfEeomalfnoKx7dA0CVuwtPC3jQTB3ts"
	var redirect_uri: String
	var refresh_token: String
	
	init(refresh_token: String, redirect_uri: String) {
		self.refresh_token = refresh_token
		self.redirect_uri = redirect_uri
	}
}
