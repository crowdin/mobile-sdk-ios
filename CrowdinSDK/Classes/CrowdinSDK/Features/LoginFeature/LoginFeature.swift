//
//  LoginFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/20/19.
//

import Foundation

class LoginFeature {
    static func login(completion: @escaping (_ csrfToken: String, _ userAgent: String, _ cookies: [HTTPCookie]) -> Void, error: @escaping (Error) -> Void) {
        guard let loginVC = CrowdinLoginVC.instantiateVC else {
            error(NSError(domain: "Unable to instantiate CrowdinLoginVC.", code: -9999, userInfo: nil))
            return
        }
        loginVC.completion = { csrfToken, userAgent, cookies in
            completion(csrfToken, userAgent, cookies)
        }
        loginVC.error = error
        loginVC.present()
    }
    
    static func relogin(completion: @escaping (_ csrfToken: String, _ userAgent: String, _ cookies: [HTTPCookie]) -> Void, error: @escaping (Error) -> Void) {
        login(completion: completion, error: error)
    }
}
