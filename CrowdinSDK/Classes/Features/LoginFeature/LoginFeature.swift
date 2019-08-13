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
	
	static var tokenExpirationDate: Date? {
		set {
			UserDefaults.standard.set(newValue, forKey: "crowdin.tokenExpirationDate.key")
			UserDefaults.standard.synchronize()
		}
		get {
			return UserDefaults.standard.object(forKey: "crowdin.tokenExpirationDate.key") as? Date
		}
	}
	
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
		guard let tokenExpirationDate = tokenExpirationDate else { return false }
		return tokenExpirationDate > Date() && tokenResponse?.accessToken != nil
    }
	
	static var accessToken: String? {
		guard let tokenExpirationDate = tokenExpirationDate else { return nil }
		if tokenExpirationDate < Date() {
			_ = refreshTokenSync()
		}
		return tokenResponse?.accessToken
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
                    let response = try JSONDecoder().decode(TokenResponse.self, from: data)
					self.tokenExpirationDate = Date(timeIntervalSinceNow: TimeInterval(response.expiresIn))
					self.tokenResponse = response
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
	
	static func refreshToken(completion: @escaping () -> Void, errorHandler: @escaping (Error) -> Void) {
		var request = URLRequest(url: URL(string: tokenStringURL)!)
		guard let refresh_token = tokenResponse?.refreshToken else { return }
		
		let tokenRequest = RefreshTokenRequest(refresh_token: refresh_token, redirect_uri: "crowdintest://")
		request.httpBody = try? JSONEncoder().encode(tokenRequest)
		request.allHTTPHeaderFields = [:]
		request.allHTTPHeaderFields?["Content-Type"] = "application/json"
		request.httpMethod = "POST"
		
		URLSession.shared.dataTask(with: request) { (data, response, error) in
			if let data = data {
				do {
					let response = try JSONDecoder().decode(TokenResponse.self, from: data)
					self.tokenExpirationDate = Date(timeIntervalSinceNow: TimeInterval(response.expiresIn))
					self.tokenResponse = response
					completion()
				} catch {
					errorHandler(error)
				}
			} else if let error = error {
				errorHandler(error)
			} else {
				errorHandler(NSError(domain: "Unknown error", code: defaultCrowdinErrorCode, userInfo: nil))
			}
		}.resume()
	}
	
	static func refreshTokenSync() -> Bool {
		var result = false
		let semaphore = DispatchSemaphore(value: 0)
		refreshToken (completion: {
			result = true
			semaphore.signal()
		}) { _ in
			result = false
			semaphore.signal()
		}
		semaphore.wait()
		return result
	}
}
