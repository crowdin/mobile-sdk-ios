//
//  LocalizationProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/31/19.
//

import Foundation

public typealias LocalizationProviderHandler = () -> Void

@objc public protocol LocalizationProvider {
    var localizationCompleted: LocalizationProviderHandler { get set }
	var localizations: [String] { get }
	var localizationDict: [String: String]  { get }
	init(localizationCompleted: @escaping LocalizationProviderHandler)
	init(localization: String, localizationCompleted: @escaping LocalizationProviderHandler)
	func deintegrate()
    func setLocalization(_ localization: String?)
}
