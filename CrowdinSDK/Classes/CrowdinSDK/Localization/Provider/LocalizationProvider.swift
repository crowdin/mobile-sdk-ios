//
//  LocalizationProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/31/19.
//

import Foundation

@objc public protocol LocalizationProvider {
    var localization: String { get set }
    var localizations: [String] { get set }
    var strings: [String : String] { get set }
    var plurals: [AnyHashable : Any] { get set }
    func deintegrate()
    func set(localization: String?)
    func set(strings: [String: String])
    func set(plurals: [AnyHashable : Any])
    func localizedString(for key: String) -> String?
    func key(for string: String) -> String?
    func values(for string: String, with format: String) -> [Any]?
}
