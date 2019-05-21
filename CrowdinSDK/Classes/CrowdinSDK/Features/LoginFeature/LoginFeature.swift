//
//  LoginFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/20/19.
//

import Foundation

struct CrowdinLoginInfo {
    var csrfToken: String
    var userAgent: String
    var cookies: [HTTPCookie]
}

class LoginFeature {
    static var loginInfo: CrowdinLoginInfo?
    
    static func login(completion: @escaping (_ csrfToken: String, _ userAgent: String, _ cookies: [HTTPCookie]) -> Void, error: @escaping (Error) -> Void) {
        if let loginInfo = LoginFeature.loginInfo {
            completion(loginInfo.csrfToken, loginInfo.userAgent, loginInfo.cookies)
            return
        }
        
        guard let loginVC = CrowdinLoginVC.instantiateVC else {
            error(NSError(domain: "Unable to instantiate CrowdinLoginVC.", code: -9999, userInfo: nil))
            return
        }
        loginVC.completion = { csrfToken, userAgent, cookies in
            completion(csrfToken, userAgent, cookies)
            loginInfo = CrowdinLoginInfo(csrfToken: csrfToken, userAgent: userAgent, cookies: cookies)
        }
        loginVC.error = error
        // TODO: Change screen presentation.
        UIApplication.shared.keyWindow?.rootViewController?.present(loginVC, animated: true, completion: { })
    }
    
    static func relogin(completion: @escaping (_ csrfToken: String, _ userAgent: String, _ cookies: [HTTPCookie]) -> Void, error: @escaping (Error) -> Void) {
        LoginFeature.loginInfo = nil
        login(completion: completion, error: error)
    }
}
