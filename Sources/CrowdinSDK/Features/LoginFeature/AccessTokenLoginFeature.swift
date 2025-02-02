//
//  AccessTokenLoginFeature.swift
//  Pods
//
//  Created by Serhii Londar on 23.11.2024.
//
import Foundation

final class AccessTokenLoginFeature: AnyLoginFeature {
    var accessToken: String?

    init(accessToken: String) {
        self.accessToken = accessToken
    }

    var isLogined: Bool { accessToken != nil }

    func login(completion: @escaping () -> Void, error: @escaping (any Error) -> Void) {
        self.accessToken = CrowdinSDK.config.accessToken
        completion()
    }

    func relogin(completion: @escaping () -> Void, error: @escaping (any Error) -> Void) {
        self.accessToken = CrowdinSDK.config.accessToken
        completion()
    }

    func hadle(url: URL) -> Bool {
        return false
    }

    func logout() {
        logout(clearCreditials: false, completion: nil)
    }

    func logout(clearCreditials: Bool, completion: (() -> Void)?) {
        if clearCreditials {
            accessToken = nil
        }
        completion?()
    }
}
