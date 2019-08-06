//
//  LoginFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/20/19.
//

import Foundation

protocol LoginFeatureProtocol {
    static func login(completion: @escaping (_ csrfToken: String, _ userAgent: String, _ cookies: [HTTPCookie]) -> Void, error: @escaping (Error) -> Void)
    static func relogin(completion: @escaping (_ csrfToken: String, _ userAgent: String, _ cookies: [HTTPCookie]) -> Void, error: @escaping (Error) -> Void)
    static func logout()
}

struct LoginInfo {
    var csrfToken: String
    var userAgent: String
    var cookies: [HTTPCookie]
}

class LoginFeature: LoginFeatureProtocol {
    static var loginInfo: LoginInfo? = nil
    
    static func login(completion: @escaping (_ csrfToken: String, _ userAgent: String, _ cookies: [HTTPCookie]) -> Void, error: @escaping (Error) -> Void) {
        if let loginInfo = loginInfo {
            completion(loginInfo.csrfToken, loginInfo.userAgent, loginInfo.cookies)
            return
        }
        let loginVC = CrowdinLoginVC()
        loginVC.completion = { csrfToken, userAgent, cookies in
            self.loginInfo = LoginInfo(csrfToken: csrfToken, userAgent: userAgent, cookies: cookies)
            completion(csrfToken, userAgent, cookies)
        }
        loginVC.error = error
        loginVC.present()
    }
    
    static func relogin(completion: @escaping (_ csrfToken: String, _ userAgent: String, _ cookies: [HTTPCookie]) -> Void, error: @escaping (Error) -> Void) {
        HTTPCookieStorage.shared.removeCookies(since: Date(timeIntervalSinceNow: 60 * 60))
        self.loginInfo = nil
        login(completion: completion, error: error)
    }
    
    static func logout() {
        HTTPCookieStorage.shared.removeCookies(since: Date(timeIntervalSinceNow: 24 * 60 * 60))
        loginInfo = nil
    }
	
	static var code: String? = nil
	
	static func hadle(url: URL) -> Bool {
		let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
		guard let queryItems = components?.queryItems else { return false }
		guard let code = queryItems.first(where: { $0.name == "code" })?.value else { return false }
		self.code = code
		self.getAutorizationToken(with: code)
		return true
	}
	static let tokenStringURL = "https://api-tester:VmpFqTyXPq3ebAyNksUxHwhC@accounts.crowdin.com/oauth/token"
	static var accessToken: String? = nil
	
	enum Params: String {
		case grant_type
		case client_id
		case client_secret
		case code
	}
	
	static func getAutorizationToken(with code: String) {
		var request = URLRequest(url: URL(string: tokenStringURL)!)
		
		let tokenRequest = TokenRequest(code: code)
		request.httpBody = try? JSONEncoder().encode(tokenRequest)
		request.allHTTPHeaderFields = [:]
		request.allHTTPHeaderFields?["Content-Type"] = "application/json"
		request.httpMethod = "POST"
		
		URLSession.shared.dataTask(with: request) { (data, response, error) in
			if let data = data {
				print(String(data: data, encoding: .utf8))
			}
			print(response)
		}.resume()
	}
}
