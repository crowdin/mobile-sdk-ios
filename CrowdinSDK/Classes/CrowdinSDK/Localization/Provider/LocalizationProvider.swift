//
//  LocalizationProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/31/19.
//

import Foundation

@objc public  protocol LocalizationProvider {
	var localizations: [String] { get }
	var localizationDict: [String: String]  { get }
	var localization: String { get set }
	init(localization: String)
	func deintegrate()
}
