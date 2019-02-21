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
    var strings: [AnyHashable : Any] { get set }
    var plurals: [AnyHashable : Any] { get set }
    init(localizations: [String], strings: [String : String], plurals: [AnyHashable : Any])
    func deintegrate()
    func set(localization: String?)
    func set(strings: [AnyHashable: Any])
    func set(plurals: [AnyHashable : Any])
    func localizedString(for key: String) -> String?
    func keyForString(_ text: String) -> String?
	// TODO: Move this method from this protocol.
	func findValues(for string: String, with format: String) -> [Any]
}
