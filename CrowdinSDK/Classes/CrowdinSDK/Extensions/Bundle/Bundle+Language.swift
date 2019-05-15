//
//  Bundle+Language.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/5/19.
//

import Foundation

// MARK: - Extension 
extension Bundle {
    /// Returns detected preffered language from device settings and bundle localizations. If bundle localizations is empty then return default locazation - "en".
    var preferredLanguage: String {
        return self.preferredLanguages.first ?? defaultLocalization
    }
    
    /// Return ordered list of language codes according to device settings, and bundle localizations.
	//	TODO: Add handling case when intersection of preffered languages from settings and localizations in bundle is empty.
    var preferredLanguages: [String] {
        var preferredLanguages = Locale.preferredLocalizations
		let localizations = self.localizations.compactMap { (localization) -> String? in
			if preferredLanguages.contains(localization) {
				return localization
			}
			return nil
		}
		preferredLanguages = preferredLanguages.compactMap { (localization) -> String? in
			if localizations.contains(localization) {
				return localization
			}
			return nil
		}
        return preferredLanguages
    }
    
    /// Returns detected preffered language from device settings and passed localizations. If bundle localizations is empty then return default locazation - "en".
    func preferredLanguage(with availableLanguages: [String]) -> String {
        return self.preferredLanguages(with: availableLanguages).first ?? defaultLocalization
    }
    
    /// Return ordered list of language codes according to device settings, and passed localizations.
    func preferredLanguages(with availableLanguages: [String]) -> [String] {
        var preferredLanguages = Locale.preferredLocalizations
        let localizations = availableLanguages.compactMap { (localization) -> String? in
            if preferredLanguages.contains(localization) {
                return localization
            }
            return nil
        }
        preferredLanguages = preferredLanguages.compactMap { (localization) -> String? in
            if localizations.contains(localization) {
                return localization
            }
            return nil
        }
        return preferredLanguages
    }
}
