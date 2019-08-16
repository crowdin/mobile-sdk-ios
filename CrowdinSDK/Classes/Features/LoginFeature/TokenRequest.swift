//
//  TokenRequest.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 8/6/19.
//

import Foundation

struct TokenRequest: Codable {
	var grant_type: String = "authorization_code"
	var client_id: String
	var client_secret: String
	var code: String
	var redirect_uri: String
	
	init(code: String, client_id: String, client_secret: String, redirect_uri: String) {
		self.code = code
		self.client_id = client_id
		self.client_secret = client_secret
		self.redirect_uri = redirect_uri
	}
}
