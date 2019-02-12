//
//  LocalizationProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/31/19.
//

import Foundation

@objc public protocol LocalizationProvider {
    var localization: String { get }
	var localizations: [String] { get }
	init(localization: String?)
	func deintegrate()
    func set(localization: String?)
	
    func localizedString(for key: String) -> String?
    func keyForString(_ text: String) -> String?
}
