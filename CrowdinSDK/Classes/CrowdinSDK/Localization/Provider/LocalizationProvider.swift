//
//  LocalizationProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/31/19.
//

import Foundation

public typealias LocalizationProviderHandler = () -> Void

@objc public protocol LocalizationProvider {
    var localization: String { get }
	var localizations: [String] { get }
	var localizationDict: [String: String]  { get }
	init(localization: String?)
	func deintegrate()
    func set(localization: String?)
}
