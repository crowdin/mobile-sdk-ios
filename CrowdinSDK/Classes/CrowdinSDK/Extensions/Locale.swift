//
//  Locale.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/5/19.
//

import Foundation

extension Locale {
	enum Keys: String {
		case kCFLocaleLanguageCodeKey
		case kCFLocaleCountryCodeKey
		case kCFLocaleScriptCodeKey
	}
	static var preferredLocalizations: [String] {
		return Locale.preferredLanguages.compactMap ({
			var components = Locale.components(fromIdentifier: $0)
			if let regionCode = Locale.current.regionCode, let countryCode = components[Keys.kCFLocaleCountryCodeKey.rawValue], regionCode == countryCode {
				components[Keys.kCFLocaleCountryCodeKey.rawValue] = nil
			}
			// TODO: find a better way of getting language identifiers without replacing "_" to "-".
			return Locale.identifier(fromComponents: components).replacingOccurrences(of: "_", with: "-")
		})
	}
}
