//
//  LoginFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/20/19.
//

import Foundation

protocol LoginFeatureProtocol {
	static var shared: Self? { get }
	static var isLogined: Bool { get }
	static func configureWith(with config: LoginConfig)
	
	func login(completion: @escaping () -> Void, error: @escaping (Error) -> Void)
	func relogin(completion: @escaping () -> Void, error: @escaping (Error) -> Void)
	func logout()
}

final class LoginFeature: LoginFeatureProtocol {
	var config: CrowdinLoginConfig
	
	static var shared: LoginFeature?
	
	private var code: String? = nil
	private var loginURL: String {
		return "https://api-tester:VmpFqTyXPq3ebAyNksUxHwhC@accounts.crowdin.com/oauth/authorize?client_id=\(config.clientId)&response_type=code&scope=\(config.scope)&redirect_uri=\(config.redirectURI)"
	}
	private let tokenStringURL = "https://api-tester:VmpFqTyXPq3ebAyNksUxHwhC@accounts.crowdin.com/oauth/token"
	
	init(config: CrowdinLoginConfig) {
		self.config = config
	}
	
	static func configureWith(with config: LoginConfig) {
		guard let crowdinConfig = config as? CrowdinLoginConfig else { return }
		LoginFeature.shared = LoginFeature(config: crowdinConfig)
	}
	
	var tokenExpirationDate: Date? {
		set {
			UserDefaults.standard.set(newValue, forKey: "crowdin.tokenExpirationDate.key")
			UserDefaults.standard.synchronize()
		}
		get {
			return UserDefaults.standard.object(forKey: "crowdin.tokenExpirationDate.key") as? Date
		}
	}
	
	var tokenResponse: TokenResponse? {
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
	var completion: (() -> Void)?  = nil
	var error: ((Error) -> Void)?  = nil
	
	static var isLogined: Bool {
		return shared?.tokenResponse?.accessToken != nil && shared?.tokenResponse?.refreshToken != nil
	}
	
	var accessToken: String? {
		guard let tokenExpirationDate = tokenExpirationDate else { return nil }
		if tokenExpirationDate < Date() {
			_ = refreshTokenSync()
		}
		return tokenResponse?.accessToken
	}
	
	func login(completion: @escaping () -> Void, error: @escaping (Error) -> Void) {
		self.completion = completion
		self.error = error
		UIApplication.shared.openURL(URL(string: self.loginURL)!)
	}
	
	func relogin(completion: @escaping () -> Void, error: @escaping (Error) -> Void) {
		self.logout()
		login(completion: completion, error: error)
	}
	
	func logout() {
		tokenResponse = nil
		LoginFeature.shared = nil
	}
	
	func hadle(url: URL) -> Bool {
		let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
		guard let queryItems = components?.queryItems else { return false }
		guard let code = queryItems.first(where: { $0.name == "code" })?.value else { return false }
		self.code = code
		self.getAutorizationToken(with: code)
		return true
	}
}

extension LoginFeature {
	func getAutorizationToken(with code: String) {
		guard let url = URL(string: tokenStringURL) else {
			error?(NSError(domain: "Unable to create url from - \(tokenStringURL)", code: defaultCrowdinErrorCode, userInfo: nil))
			return
		}
		var request = URLRequest(url: url)
		let tokenRequest = TokenRequest(code: code, client_id: config.clientId, client_secret: config.clientSecret, redirect_uri: config.redirectURI)
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
	
	func refreshToken(completion: @escaping () -> Void, errorHandler: @escaping (Error) -> Void) {
		var request = URLRequest(url: URL(string: tokenStringURL)!)
		guard let refresh_token = tokenResponse?.refreshToken else { return }
		
		let tokenRequest = RefreshTokenRequest(refresh_token: refresh_token, client_id: config.clientId, client_secret: config.clientSecret, redirect_uri: config.redirectURI)
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
	
	func refreshTokenSync() -> Bool {
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
