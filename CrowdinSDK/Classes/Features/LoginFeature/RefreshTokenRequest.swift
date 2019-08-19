//
//  RefreshTokenRequest.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 8/12/19.
//

import Foundation

struct RefreshTokenRequest: Codable {
	var grant_type: String = "refresh_token"
	var client_id: String
	var client_secret: String
	var redirect_uri: String
	var refresh_token: String
	
	init(refresh_token: String, client_id: String, client_secret: String, redirect_uri: String) {
		self.refresh_token = refresh_token
		self.client_id = client_id
		self.client_secret = client_secret
		self.redirect_uri = redirect_uri
	}
}
