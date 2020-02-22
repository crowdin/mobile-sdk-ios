//
//  CrowdinLoginConfig.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 8/16/19.
//

import Foundation

@objcMembers public class CrowdinLoginConfig: NSObject {
	var clientId: String
	var clientSecret: String
	var scope: String
	var redirectURI: String
	var organizationName: String? = nil
	
	public init(clientId: String, clientSecret: String, scope: String, redirectURI: String) throws {
        guard !clientId.isEmpty else { throw NSError(domain: "clientId could not be empty.", code: defaultCrowdinErrorCode, userInfo: nil) }
		self.clientId = clientId
        guard !clientSecret.isEmpty else { throw NSError(domain: "clientSecret could not be empty.", code: defaultCrowdinErrorCode, userInfo: nil) }
		self.clientSecret = clientSecret
        guard !scope.isEmpty else { throw NSError(domain: "scope could not be empty.", code: defaultCrowdinErrorCode, userInfo: nil) }
		self.scope = scope
        guard !redirectURI.isEmpty else { throw NSError(domain: "redirectURI could not be empty.", code: defaultCrowdinErrorCode, userInfo: nil) }
        guard let urlSchemes = Bundle.main.urlSchemes, urlSchemes.contains(redirectURI) else { throw NSError(domain: "Application supported url schemes should contain \(redirectURI)", code: defaultCrowdinErrorCode, userInfo: nil) }
		self.redirectURI = redirectURI
	}
}
