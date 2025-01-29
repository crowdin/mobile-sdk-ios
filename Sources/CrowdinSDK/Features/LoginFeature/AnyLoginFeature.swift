//
//  AnyLoginFeature.swift
//  Pods
//
//  Created by Serhii Londar on 23.11.2024.
//
import Foundation

protocol AnyLoginFeature: CrowdinAuth {
    var isLogined: Bool { get }

    func login(completion: @escaping () -> Void, error: @escaping (Error) -> Void)
    func relogin(completion: @escaping () -> Void, error: @escaping (Error) -> Void)

    func hadle(url: URL) -> Bool

    func logout()
    func logout(clearCreditials: Bool, completion: (() -> Void)?)
}
