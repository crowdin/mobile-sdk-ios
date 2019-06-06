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
}
