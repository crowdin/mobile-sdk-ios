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
	static func configureWith(with hash: String, loginConfig: CrowdinLoginConfig)
	
	func login(completion: @escaping () -> Void, error: @escaping (Error) -> Void)
	func relogin(completion: @escaping () -> Void, error: @escaping (Error) -> Void)
	func logout()
}

final class LoginFeature: LoginFeatureProtocol, CrowdinAuth {
	var config: CrowdinLoginConfig
	
	static var shared: LoginFeature?
	
    private var loginAPI: LoginAPI
    
    init(hash: String, config: CrowdinLoginConfig) {
		self.config = config
        self.loginAPI = LoginAPI(clientId: config.clientId, clientSecret: config.clientSecret, scope: config.scope, redirectURI: config.redirectURI, organizationName: config.organizationName)
        if self.hash != hash {
            self.logout()
        }
        self.hash = hash
        NotificationCenter.default.addObserver(self, selector: #selector(receiveUnautorizedResponse), name: .CrowdinAPIUnautorizedNotification, object: nil)
	}
	
    static func configureWith(with hash: String, loginConfig: CrowdinLoginConfig) {
        LoginFeature.shared = LoginFeature(hash: hash, config: loginConfig)
	}
    
    var hash: String {
        set {
            UserDefaults.standard.set(newValue, forKey: "crowdin.hash.key")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "crowdin.hash.key") ?? ""
        }
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
			let data = try? JSONEncoder().encode(newValue)
			UserDefaults.standard.set(data, forKey: "crowdin.tokenResponse.key")
			UserDefaults.standard.synchronize()
		}
		get {
			guard let data = UserDefaults.standard.data(forKey: "crowdin.tokenResponse.key") else { return nil }
			return try? JSONDecoder().decode(TokenResponse.self, from: data)
		}
	}
	
	static var isLogined: Bool {
		return shared?.tokenResponse?.accessToken != nil && shared?.tokenResponse?.refreshToken != nil
	}
	
	var accessToken: String? {
		guard let tokenExpirationDate = tokenExpirationDate else { return nil }
		if tokenExpirationDate < Date() {
            if let refreshToken = tokenResponse?.refreshToken, let response = loginAPI.refreshTokenSync(refreshToken: refreshToken) {
                self.tokenExpirationDate = Date(timeIntervalSinceNow: TimeInterval(response.expiresIn))
                self.tokenResponse = response
            } else {
                logout()
            }
		}
		return tokenResponse?.accessToken
	}
    
    func login(completion: @escaping () -> Void, error: @escaping (Error) -> Void) {
        loginAPI.login(completion: { (tokenResponse) in
            self.tokenExpirationDate = Date(timeIntervalSinceNow: TimeInterval(tokenResponse.expiresIn))
            self.tokenResponse = tokenResponse
        }, error: error)
	}
	
	func relogin(completion: @escaping () -> Void, error: @escaping (Error) -> Void) {
		logout()
		login(completion: completion, error: error)
	}
	
	func logout() {
		tokenResponse = nil
		tokenExpirationDate = nil
	}
	
	func hadle(url: URL) -> Bool {
        return loginAPI.hadle(url: url)
	}
    
    @objc func receiveUnautorizedResponse() {
        logout()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
