//
//  LoginFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/20/19.
//

import Foundation

protocol LoginFeatureProtocol {
    static var isLogined: Bool { get }
    static func login(completion: @escaping () -> Void, error: @escaping (Error) -> Void)
    static func relogin(completion: @escaping () -> Void, error: @escaping (Error) -> Void)
    static func logout()
}

class LoginFeature: LoginFeatureProtocol {
    static var loginURL = "https://api-tester:VmpFqTyXPq3ebAyNksUxHwhC@accounts.crowdin.com/oauth/authorize?client_id=test-sdk&response_type=code&scope=project.content.screenshots&redirect_uri=crowdintest://"
    
    static var tokenResponse: TokenResponse? {
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(data, forKey: "crowdin.tokenResponse.key")
            UserDefaults.standard.synchronize()
        }
        get {
            guard let data = UserDefaults.standard.data(forKey: "crowdin.tokenResponse.key") else { return nil }
            return try? JSONDecoder().decode(TokenResponse.self, from: data)
        }
    }
    static var completion: (() -> Void)?  = nil
    static var error: ((Error) -> Void)?  = nil
    
    static var isLogined: Bool {
        return self.tokenResponse?.accessToken != nil
    }
    
    static func login(completion: @escaping () -> Void, error: @escaping (Error) -> Void) {
        self.completion = completion
        self.error = error
        UIApplication.shared.openURL(URL(string: self.loginURL)!)
    }
    
    static func relogin(completion: @escaping () -> Void, error: @escaping (Error) -> Void) {
        self.logout()
        login(completion: completion, error: error)
    }
    
    static func logout() {
        // TODO:
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
	
	enum Params: String {
		case grant_type
		case client_id
		case client_secret
		case code
	}
	
	static func getAutorizationToken(with code: String) {
		var request = URLRequest(url: URL(string: tokenStringURL)!)
		
        let tokenRequest = TokenRequest(code: code, redirect_uri: "crowdintest://")
		request.httpBody = try? JSONEncoder().encode(tokenRequest)
		request.allHTTPHeaderFields = [:]
		request.allHTTPHeaderFields?["Content-Type"] = "application/json"
		request.httpMethod = "POST"
		
		URLSession.shared.dataTask(with: request) { (data, response, error) in
			if let data = data {
                do {
                    self.tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                    self.completion?()
                } catch {
                    self.error?(error)
                }
            } else if let error = error {
                self.error?(error)
            } else {
                self.error?(NSError(domain: "Unknown error", code: defaultCrowdinErrorCode, userInfo: nil))
            }
		}.resume()
	}
}
